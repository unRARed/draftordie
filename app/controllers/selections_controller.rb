class SelectionsController < ApplicationController
  before_action :set_selection

  def edit
    unless @selection.draft.is_started?
      @draft = Draft.preloaded.find(@selection.draft_id)
      flash[:alert] = "Draft has not started yet"
      return render "drafts/show"
    end

    unless @selection.draft.current_selection == @selection
      @draft = Draft.preloaded.find(@selection.draft_id)
      flash[:alert] = "It's not your turn to select"
      return render "drafts/show"
    end
  end

  def update
    if @selection.update(selection_params)
      redirect_to member_draft_path(@selection.draft)
    else
      render :edit
    end
  end

private

  def selection_params
    params.require(:selection).permit(
      :write_in_name,
      :write_in_position,
      :player_id
    )
  end

  def set_selection
    @selection = Selection.find(params[:id])
    authorize @selection
  end
end
