class DraftsController < ApplicationController
  before_action :set_draft,
    except: [:show, :commish, :member, :board]
  before_action :load_full_draft,
    only: [:show, :commish, :member, :board]
  before_action :check_access_code,
    except: [:index, :new, :create, :access, :verify_access]
  before_action :authenticate_user!,
    except: [:show, :access, :verify_access]
  skip_after_action :verify_policy_scoped, :only => :index

  def index
    redirect_to root_path
  end

  def access; end

  def verify_access
    access_code =
      params[:access_code].upcase

    unless @draft.access_code == access_code
      flash[:alert] = "Invalid access code"
      return redirect_to access_draft_path(@draft,
        params: { access_code: access_code}
      )
    end
    session["draft_#{@draft.slug}_access_code"] = access_code
    redirect_to draft_path(@draft)
  end

  def join
    if @draft.is_running?
      flash[:alert] = "Draft has already started."
    elsif @draft.users.count >= @draft.user_count
      flash[:alert] = "Draft is full."
    elsif @draft.users.include?(current_user)
      flash[:alert] = "You all already in this draft!"
    else
      @draft.users << current_user
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
    return render 'show' unless @selection = @draft.current_selection
    if @selection.user == current_user
      return redirect_to(edit_draft_selection_path(
        @selection.draft, @selection
      ))
    end

    # JUST FOR NOW
    render "show"
  end

  def board

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
    end

    # guard clause to prevent restarting a draft
    return if @draft.started_at.present?

    # start the draft and put the current selection
    # on the clock
    @draft.update started_at: Time.current
    @draft.current_selection.update started_at: Time.current
    flash[:notice] = "Draft has begun!"
  ensure
    redirect_to draft_path(@draft)
  end

  def pause
    return if @draft.is_paused?

    @draft.update is_paused: true
    flash[:notice] = "Draft has been paused!"
    redirect_to draft_path(@draft)
  end

  def start_next_selection
    render json: @draft.current_selection.time_remaining
    # return unless @draft.is_between_selections?
    # @draft.current_selection.update! ended_at: Time.current

    # return if @draft.current_selection.nil?
    # @draft.current_selection.reload.
    #   update! started_at: Time.current
  end

  def generate
    @draft.generate_board
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
