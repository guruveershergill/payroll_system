class UsersController < ApplicationController
  before_action :set_user, only: [:view_salary_slip_details, :send_salary_slip_email]

  def new
    @user = User.new
    render shared: 'application'
  end

  def index
    @users = User.all
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to dashboard_path, notice: 'Employee created successfully!'
    else
      render 'new'
    end
  end

  def salary_slip
    @users = User.all
    @selected_month = params[:month].to_i if params[:month].present?
  end

  def view_salary_slip_details
    @user = User.find(params[:id])
    year = Date.current.year
    month = params[:month].to_i || 12
    @holiday_service = HolidayService.new

    salary_service = SalarySlipService.new(@user)
    @salary_details = salary_service.calculate_salary(year, month)
  end

  def send_salary_slip_email
    @user = User.find(params[:id])
    salary_service = SalarySlipService.new(@user)
    salary_details = salary_service.calculate_salary(Date.current.year, Date.current.month)
    salary_service.send_salary_slip_email(salary_details)

    flash[:notice] = 'Salary slip sent successfully!'
    redirect_to salary_slip_users_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :employee_code, :email, :password, :current_salary, :is_hr, :user_id)
  end
end
