class PairingPolicy < ApplicationPolicy
  def destroy?
    record.pairable.user == user
  end
end
