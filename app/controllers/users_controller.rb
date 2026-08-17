# frozen_string_literal: true

# # app/controllers/users_controller.rb
class UsersController < ApplicationController
#     def index
#       @inactive_users = UsersListQuery.inactive
#       @active_users = UsersListQuery.active
#       @most_active_users = UsersListQuery.most_active
#     end

#     def show
#       @user = UsersListQuery.find_by_id(params[:id])
#       if @user.nil?
#         redirect_to users_path, alert: 'User not found'
#       end
#     end

#     def new
#       @user = User.new
#     end

#     def create
#       @user = UsersListQuery.create_user(user_params)
#       if @user.save
#         redirect_to @user, notice: 'User was successfully created.'
#       else
#         render :new
#       end
#     end

#     def edit
#       @user = UsersListQuery.find_by_id(params[:id])
#       if @user.nil?
#         redirect_to users_path, alert: 'User not found'
#       end
#     end

#     def update
#       @user = UsersListQuery.update_user(params[:id], user_params)
#       if @user&.valid?
#         redirect_to @user, notice: 'User was successfully updated.'
#       else
#         render :edit
#       end
#     end

#     def destroy
#       @user = UsersListQuery.destroy_user(params[:id])
#       if @user
#         redirect_to users_path, notice: 'User was successfully destroyed.'
#       else
#         redirect_to users_path, alert: 'User not found'
#       end
#     end

#     private

#     def user_params
#       params.require(:user).permit(:name, :email, :password, :sign_in_count, :verified)
#     end
end
