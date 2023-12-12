module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :set_transaction, only: [:show, :update, :destroy]

      def index
        render json: serialized_transactions
      end

      def show
        render json: @transaction
      end

      def new
        render json: { transaction: new_transaction, categories: serialized_categories }
      end

      def create
        @transaction = Transaction.new(transaction_params)
        if @transaction.save
          render json: @transaction, status: :created
        else
          render json: @transaction.errors, status: :unprocessable_entity
        end
      end

      def update
        if @transaction.update(transaction_params)
          render json: @transaction
        else
          render json: @transaction.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @transaction.update(archived: true)
        render json: serialized_transactions
      end

      def archive
        @transactions = Transaction.where(archived: true)
        render json: @transactions.map { |transaction| serialize_transaction(transaction) }
      end

      def filter
        @transactions = Transaction.all
        filter_transactions
        render json: @transactions.map { |transaction| serialize_transaction(transaction) }
      end

      private

      def serialized_transactions
        Transaction.where(archived: false).map { |transaction| serialize_transaction(transaction) }
      end

      def filter_transactions
        @transactions = @transactions.by_category(params[:category]) if params[:category].present?
        @transactions = @transactions.by_date_range(params[:start_date], params[:end_date]) if params[:start_date].present? && params[:end_date].present?
        @transactions = @transactions.by_period(params[:period]) if params[:period].present?
        @transactions = @transactions.by_title(params[:title]) if params[:title].present?
        @transactions = @transactions.by_bank_name(params[:bank_name]) if params[:bank_name].present?
        @transactions = @transactions.by_period(params[:period]) if params[:period]
      end

      def serialize_transaction(transaction)
        {
          id: transaction.id,
          title: transaction.title,
          description: transaction.description,
          category: transaction.category.name,
          amount: transaction.amount,
          bank_name: transaction.bank_name,
          created_at: transaction.created_at,
          updated_at: transaction.updated_at
        }
      end

      def new_transaction
        Transaction.new
      end

      def serialized_categories
        Category.all.map { |category| { id: category.id, name: category.name } }
      end

      def set_transaction
        @transaction = Transaction.find(params[:id])
      end

      def transaction_params
        params.require(:transaction).permit(:title, :description, :category_id, :amount, :bank_name, :archived)
      end
    end
  end
end
