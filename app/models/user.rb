class User < ApplicationRecord
	
	has_many :articles, dependent: :destroy
	has_many :comments, dependent: :destroy

	validates :username, presence: :true, uniqueness: { case_sensitive: false }
	# Only allow letter, number, underscore and punctuation.
	validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, :multiline => true

	after_initialize :set_default_role, :if => :new_record?

	enum role: [:user, :vip, :admin, :supplier, :employee]

	serialize :data

	attr_writer :login

	def login
		@login || self.username || self.email
	end

	def set_default_role
		self.role ||= :user
	end

	def collect_yahoo_token(code)
		data = Hash.new
		data[:yahoo] = Hash.new
		data[:yahoo][:login_token_code] = Hash.new
		data[:yahoo][:login_token_code][:token_code] = code
		data[:yahoo][:login_token_code][:acquired] = DateTime.now
		self.data.nil? ? (self.data = data) : (self.data = self.data.merge(data))
		self.save
	end

	#def active_for_authentication? 
	#	super && approved? 
	#end 

	#def inactive_message 
	#	approved? ? super : :not_approved
	#end
	
	def self.find_for_database_authentication(warden_conditions)
		conditions = warden_conditions.dup
		if login = conditions.delete(:login)
			where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
		elsif conditions.has_key?(:username) || conditions.has_key?(:email)
			where(conditions.to_h).first
		end
	end

	protected
	def confirmation_required?
	  true
	end
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable, :confirmable,
		:recoverable, :rememberable, :trackable, :validatable, authentication_keys: [:login]
end
