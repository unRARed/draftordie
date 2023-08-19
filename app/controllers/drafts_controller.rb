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
    :verify_access, :create_pairing
  ]
  before_action :authenticate_user!,
    except: [:show, :board, :access, :verify_access]
  before_action :build_draft_navigation
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
      @draft.users.delete(current_user)
      flash[:alert] = "You have been removed from this draft."
    else
      flash[:notice] = "You're not in this draft!"
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
    @draft.users << current_user

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

  def start
    # if paused, we only reset the timer
    # for the current selection and unpause
    if @draft.is_paused?
      @draft.current_selection.update started_at: Time.current
      @draft.update is_paused: false
      flash[:notice] = "Draft has resumed!"
      DraftChannel.broadcast_to(@draft, {
        command: "refresh", payload: {}
      })
    end

    # guard clause to prevent restarting a draft
    return if @draft.started_at.present?

    # start the draft and put the current selection
    # on the clock
    Draft.transaction do
      @draft.upcoming_selections.first.
        update started_at: Time.current
      @draft.update_columns started_at: Time.current
    end
    flash[:notice] = "Draft has begun!"
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

  def generate
    @draft.generate_board
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

private

  def draft_params
    params.require(:draft).permit(
      :name,
      :round_count,
      :user_count,
      :selection_seconds,
      :player_ids
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
