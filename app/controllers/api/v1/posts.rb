require 'doorkeeper/grape/helpers'

module API
  module V1
    class Posts < Grape::API
      helpers Doorkeeper::Grape::Helpers
      #
      # before do
      #   doorkeeper_authorize!
      # end
      before do
        authenticate!
        restrict_to_role %w(admin agent)
      end

      include API::V1::Defaults
      resource :posts do

        # CREATE NEW POST. THIS REPLIES TO BOTH COMMUNITY TOPICS AND PRIVATE TICKETS
        desc "Add a new post to an existing topic"
        params do
          requires :topic_id, type: Integer, desc: "Topic to add post to"
          requires :body, type: String, desc: "The post body"
          requires :user_id, type: Integer, desc: "The User ID of the poster"
          requires :kind, type: String, desc: "The kind of post, either 'reply' or 'note'"
        end
        post "create", root: :posts do
          post = Post.create!(
            topic_id: permitted_params[:topic_id],
            body: permitted_params[:body],
            user_id: permitted_params[:user_id],
            kind: permitted_params[:kind]
          )
          present post, with: Entity::Post
        end

        # UPDATE POST. THIS REPLIES TO BOTH COMMUNITY TOPICS AND PRIVATE TICKETS
        desc "Update existing post"
        params do
          requires :id, type: Integer, desc: "The Post ID"
          requires :body, type: String, desc: "The post body"
          requires :active, type: Boolean, desc: "Whether the post is live or not"
        end
        patch ":id", root: :posts do
          post = Post.find(permitted_params[:id])
          post.update!(
            body: permitted_params[:body],
            active: permitted_params[:active]
          )
          present post, with: Entity::Post
        end


      end
    end
  end
end
