class DraftsController < ApplicationController
  include DraftHelper
  layout "draft", except: [:index, :new, :create]

  before_action :set_draft, except: [
    :index, :new, :create, :commish,
    :member
  ]
  before_action :load_full_draft,
    only: [:show, :commish, :member, :board]
  before_action :check_access_code, except: [
    :index, :new, :create, :access,
    :verify_access, :create_pairing, :players
  ]
  before_action :authenticate_user!,
    except: [:show, :board, :access, :verify_access]
  before_action :build_draft_navigation
  before_action :put_user_on_clock, only: [:board, :edit]
  skip_after_action :verify_policy_scoped, :only => :index

  def board; end
  def access; end
  def invite; end
  def edit; end

  def join
    @pairing = @draft.pairings.build
  end

  def index
    redirect_to root_path
  end

  def verify_access
    access_code =
      params[:access_code].upcase

    unless @draft.access_code == access_code
      flash[:alert] = "Invalid access code"
      return redirect_to access_draft_path(@draft,
        params: { access_code: access_code}
      )
    end
    flash.keep
    session["draft_#{@draft.slug}_access_code"] = access_code
    redirect_to draft_path(@draft)
  end

  def create_pairing
    if @draft.is_running?
      flash[:alert] = "Draft has already started."
    elsif @draft.users.count >= @draft.user_count
      flash[:alert] = "Draft is full."
    elsif @draft.users.include?(current_user)
      flash[:alert] = "You are already in this draft!"
    else
      @draft.pairings.create!({
          user: current_user,
          context: "Draft Team Name",
        }.merge(pairing_params))
      flash[:notice] = "You have joined this draft!"
    end
    redirect_to draft_path(@draft)
  end

  def leave
    if @draft.is_running?
      flash[:alert] = "Draft has already started!"
    elsif @draft.users.include?(current_user)
      @draft.remove_user(current_user)
      flash[:notice] = "You have been removed from this draft."
    else
      flash[:warning] = "You're not in this draft!"
    end
    redirect_to draft_path(@draft)
  end

  def remove_user
    if @draft.is_running?
      flash[:alert] = "Draft has already started!"
    elsif @draft.users.include?(current_user)
      @draft.remove_user(params[:user_id])
      flash[:notice] = "Participant has been removed."
    else
      flash[:warning] = "That participant is not in this draft!"
    end
    redirect_to draft_path(@draft)
  end

  def show
    unless current_user
      flash.keep
      return redirect_to board_draft_path(@draft)
    end
    return redirect_to(
      board_draft_path(@draft)
    ) if !@draft.is_running?
  end

  def create_invite
    # send email to user inviting to draft
    DraftMailer.
      invite(draft: @draft, email: params[:email]).
      deliver_now
    flash[:notice] = "Invite sent!"
    redirect_to invite_draft_path(@draft)
  end

  def new
    @draft = Draft.new
    authorize @draft
  end

  def create
    @draft = Draft.new(draft_params)
    authorize @draft
    @draft.user = current_user
    @draft.player_pool_id = PlayerPool.last&.id || 1

    if @draft.save
      flash[:notice] = "Draft created successfully"
      redirect_to edit_draft_path(@draft)
    else
      render :new
    end
  end

  def update
    if @draft.update(draft_params)
      flash[:notice] = "Draft updated successfully"
      redirect_to edit_draft_path(@draft)
    else
      render :edit
    end
  end

  def edit_order
    prepare_order
  end

  def update_order
    if @draft.update(draft_params)
      flash[:notice] = "Draft order updated successfully"
      redirect_to order_draft_path(@draft)
    else
      prepare_order
      render :edit_order
    end
  end

  def start
    action_taken = @draft.is_paused? ?  "resumed" : "started"
    @draft.activate!
    flash[:notice] = "Draft has #{action_taken}!"
    DraftChannel.broadcast_to(@draft, {
      command: "refresh", payload: {}
    })
  ensure
    redirect_to draft_path(@draft)
  end

  def pause
    return if @draft.is_paused?

    @draft.update is_paused: true
    flash[:notice] = "Draft has been paused!"
    DraftChannel.broadcast_to(@draft, {
      command: "refresh", payload: {}
    })
    head :ok
  end

  def fill
    if @draft.is_running?
      flash[:error] =
        "Draft cannot be running when filling missing selections."
    end

    @draft.fill_missed_selections
  end

  def generate
    @draft.generate_board!
    flash[:notice] = "Draft board generated!"
    redirect_back fallback_location: draft_path(@draft)
  end

  def toggle_sound
    session[:is_sound_enabled] = !session[:is_sound_enabled]
    flash[:notice] =
      session[:is_sound_enabled] ?
        "Sound enabled!" : "Sound disabled!"

    redirect_to draft_path(@draft)
  end

  def players
    @players = @draft.remaining_players
    if params[:search].present?
      @players = @players.search_by_name(params[:search])
    end
  end

private

  def draft_params
    params.require(:draft).permit(
      :name,
      :round_count,
      :user_count,
      :selection_seconds,
      :player_ids,
      :order_pairings_attributes => [
        :id,
        :context_value,
        :user_id,
      ],
      :team_name_pairings_attributes => [
        :id,
        :context_value,
        :user_id,
      ],
    )
  end

  def pairing_params
    params.require(:pairing).permit(:context_value)
  end

  def set_draft
    unless (@draft = Draft.find_by_slug(params[:slug]))
      return redirect_back fallback_location: root_path
    end
    authorize @draft
  end

  def load_full_draft
    unless (@draft = Draft.preloaded.find_by_slug(params[:slug]))
      return redirect_back fallback_location: root_path
    end
    authorize @draft
  end

  def prepare_order
    @draft.users.each do |user|
      if @draft.order_pairings.find_by(user: user).nil?
        @draft.order_pairings.build(user: user)
      end
    end
  end

  def put_user_on_clock
    return unless @draft&.is_running?
    if current_user == @draft&.current_selection&.user
      flash[:warning] = "You're on the clock!"
      return redirect_to(draft_path(@draft))
    end
  end

  def check_access_code
    return if @draft.user == current_user

    if session["draft_#{@draft.slug}_access_code"] != @draft.access_code
      flash[:alert] = "Access to this draft is restricted"
      redirect_to access_draft_path(@draft,
        params: { access_code: params[:access_code] }
      )
    end
  end
end
