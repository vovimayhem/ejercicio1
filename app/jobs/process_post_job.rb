class ProcessPostJob < ApplicationJob
  queue_as :default

  def perform(attributes, author, post = nil)
    sleep 10.seconds

    return update_existing_post(post, attributes) if post.present?
    create_post author, attributes
  end


  private

  def update_existing_post(post, attributes = {})
    post.update! attributes
  end

  def create_post(author, attributes = {})
    post = Post.new(attributes)
    post.author = author
    post.save!
  end
end
