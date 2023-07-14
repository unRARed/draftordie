class DraftsController < ApplicationController
  before_action :set_draft, only: [
    :edit,
    :update,
    :destroy,
    :generate,
    :start,
    :start_next_selection,
    :invite,
    :create_invite,
    :access,
    :verify_and_join
  ]
  before_action :load_full_draft, only: [:show, :member]
  before_action :check_access_code,
    except: [:index, :new, :create, :access, :verify_and_join]
  skip_after_action :verify_policy_scoped, :only => :index


  def index
    redirect_to root_path
  end

  def access; end

  def verify_and_join
    access_code =
      params[:access_code].upcase

    unless @draft.access_code == access_code
      flash[:alert] = "Invalid access code"
      return redirect_to access_draft_path(@draft,
        params: { access_code: access_code}
      )
    end
    session["draft_#{@draft.slug}_access_code"] = access_code
    unless @draft.users.include?(current_user)
      @draft.users << current_user
      flash[:notice] = "You have joined the draft!"
    end
    redirect_to draft_path(@draft)
  end

  def show
    if @draft.user == current_user
      # TODO: add admin view of board w/ links
      #       to edit selections
      return render
    end

    if @draft.users.include?(current_user)
      return redirect_to member_draft_path(@draft)
    end
  end

  def member
    @selection = @draft.current_selection
    if @selection.user == current_user
      return redirect_to(edit_draft_selection_path(
        @selection.draft, @selection
      ))
    end

    # JUST FOR NOW
    render "show"
  end

  def create_invite
    # send email to user inviting to draft
    DraftMailer.
      invite(draft: @draft, email: params[:email]).
      deliver_now
    flash[:notice] = "Invite sent!"
    redirect_to invite_draft_path(@draft)
  end

  def invite; end
  def edit; end
  def new
    @draft = Draft.new
    authorize @draft
  end

  def create
    @draft = Draft.new(draft_params)
    authorize @draft
    @draft.user = current_user

    if @draft.save
      @draft.users << current_user
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
    return if @draft.started_at.present?

    @draft.update started_at: Time.current
    @draft.current_selection.update started_at: Time.current
    flash[:notice] = "Draft has begun!"
    redirect_to draft_path(@draft)
  end

  def start_next_selection
    return unless @draft.is_between_selections?

    @draft.current_selection.update! ended_at: Time.current
    @draft.current_selection.reload.
      update! started_at: Time.current
  end

  def generate
    Draft.transaction do
      current_pick_number = 1
      @draft.rounds.destroy_all
      @draft.update started_at: nil
      @draft.update ended_at: nil
      @draft.round_count.times do |num|
        round_number = num + 1
        round = @draft.rounds.create(
          number: round_number,
          is_reversed: round_number.even?
        )

        # Create selections for the round
        users = @draft.users
        users = users.reverse if round.is_reversed?
        users.each do |user|
          round.selections.create(
            user: user,
            pick_number: current_pick_number
          )
          current_pick_number += 1
        end
      end
    end
    redirect_to draft_path(@draft)
  end

private

  def draft_params
    params.require(:draft).permit(
      :name,
      :round_count,
      :player_count,
      :selection_seconds,
      :player_ids
    )
  end

  def set_draft
    @draft = Draft.find_by_slug(params[:slug])
    authorize @draft
  end

  def load_full_draft
    @draft = Draft.preloaded.find_by_slug(params[:slug])
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
