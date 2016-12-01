helpers do
    def current_user
        User.find_by(id: session[:user_id])
    end
end

get '/' do
    @posts = Post.order(created_at: :desc)
    erb (:index)
end

get '/signup' do        # navigates to path "/signup"
    @user = User.new    # setup empty @user object
    erb(:signup)        # render "app/views/signup.erb"
end

post '/signup' do
    
    # grab user input from params in signup
    email       = params[:email]
    avatar_url  = params[:avatar_url]
    username    = params[:username]
    password    = params[:password]
    
    
    #instantiate and save a User
    @user = User.new({
        email: email,
        avatar_url: avatar_url,
        username: username,
        password: password
    })
    
        #if user validations pass and user is saved
        if @user.save
            # saves username
            redirect to ('/login')
        else
            erb(:signup)
        end
end

get '/login' do
    erb(:login)
end

post '/login' do
    username = params[:username]
    password = params[:password]
    
    user = User.find_by(username: username)
    
    if user && user.password == password
        session[:user_id] = user.id
        redirect to ('/')
    else
        @error_message = "Login failed."
        erb(:login)
    end
end

get '/logout' do
    session[:user_id] = nil
    redirect to ('/')
end

get '/posts/new' do
    @post = Post.new
    erb(:"posts/new")
end

post '/posts' do
    photo_url = params[:photo_url]
    
    @post = Post.new({ photo_url: photo_url, user_id: current_user.id })
    
    if @post.save
        redirect(to('/'))
    else
        erb(:"posts/new")
    end
end

get '/posts/:id' do
    @post = Post.find(params[:id])  # find the post with the ID from the URL
    erb(:"posts/show")              # render app/views/posts/show.erb
end

post '/comments' do
    # point values from params to variables
    text = params[:text]
    post_id = params[:post_id]
    
    # instantiate a comment with those values & assign the comment to the 'current_user'
    comment = Comment.new({ text: text, post_id: post_id, user_id: current_user.id })
    
    # save the comment
    comment.save
    
    # 'redirect' back to wherever we came from
    redirect(back)
end

post '/likes' do
    post_id = params[:post_id]
    
    like = Like.new({ post_id: post_id, user_id: current_user.id})
    like.save
    
    redirect(back)
end

delete '/likes/:id' do
    like = Like.find(params[:id])
    like.destroy
    redirect(back)
end
