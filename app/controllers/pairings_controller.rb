class PairingsController < ApplicationController
  before_action :set_pairing

  def destroy
    if @pairing.destroy
      flash[:alert] = "Participant removed."
    else
      flash[:alert] = "Could not remove that participant."
    end
    redirect_back(fallback_location: root_path)
  end

private

  def pairing_params
    params.require(:pairing).permit(
      :write_in_name,
      :write_in_position,
      :player_id
    )
  end

  def set_pairing
    @pairing = Pairing.find(params[:id])
    authorize @pairing
  end
end
