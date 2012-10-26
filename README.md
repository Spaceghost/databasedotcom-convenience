# databasedotcom-convenience

A convenience module to make talking to databasedotcom convenient.

#Installation
    gem install databasedotcom-convenience

or, if you use Bundler

    gem 'databasedotcom-convenience'

# Usage

* Include `Databasedotcom::Convenience` into your class

* Create a YAML file at 'config/databasedotcom.yml' derived from your project root.
* Example below:

        ---
        client_id: put-your-client-id-here
        client_secret: put-your-client-secret-here
        username: put-your-username-here
        password: put-your-password-here
        debugging: true

  Alternatively, include environment-specific settings:
        development:
            client_id: ...
        test:
            client_id: ...
        production:
            client_id: ...



# Rails example

    class UsersController < ApplicationController
      include Databasedotcom::Convenience
      before_filter :load_user, :except => [:index, :new]

      def index
        @users = User.all
      end

      def show
      end

      def new
        @user = User.new
      end

      def create
        User.create User.coerce_params(params[:user])
        flash[:info] = "The user was created!"
        redirect_to users_path
      end

      def edit
      end

      def update
        @user.update_attributes User.coerce_params(params[:user])
        flash[:info] = "The user was updated!"
        redirect_to user_path(@user)
      end

      def destroy
        @user.delete
        flash[:info] = "The user was deleted!"
        redirect_to users_path
      end

      private

      def load_user
        @user = User.find(params[:id])
      end
    end

# Example
    module Service::Databasedotcom
      include Databasedotcom::Convenience

      def self.build_user id
        @user = User.find id
        @user['fullname'] = [@user.first_name, @user.last_name].join "  "
      end
    end

This is a contrived example. Check out the `databasedotcom` gem for more information on querying.

Note that there is no need to declare the User class anywhere- `Databasedotcom::Convenience` recognizes it as a known Sobject type from your database.com instance, and materializes it automatically.

# License

databasedotcom-convenience is released under the MIT License
