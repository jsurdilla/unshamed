class Api::V1::JournalEntriesController < ApplicationController

  before_action :authenticate_user!

  def index
    @journal_entries = current_user.journal_entries.order('updated_at DESC')
  end

  def show
    @journal_entry = current_user.journal_entries.find(params[:id])
  end

  def update
    @journal_entry = current_user.journal_entries.find(params[:id])
    if @journal_entry.update(journal_params)
      render action: :show
    else
      render json: { errors: @journal_entry.errors }, status: :unprocessable_entity
    end
  end

  def create
    @journal_entry = JournalEntry.new(journal_params)
    @journal_entry.user = current_user

    if params[:journal_entry][:published] === true
      @journal_entry.published_at = Time.now
    end

    if @journal_entry.save
      render action: :show, status: :created
    else
      render json: { errors: @journal_entry.errors }, status: :unprocessable_entity
    end
  end

  private

  def journal_params
    params.require(:journal_entry).permit(
      :title,
      :body,
      :posted_at,
      :public
    )
  end

end
