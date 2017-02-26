class StaticPagesController < ApplicationController
  require 'open-uri'
  require 'json'
  require 'uri'

  DEVELOPER_KEY ="AIzaSyDxSiM2u26mPlea4QK522XxnP2_d2CtFu0"
  
  def home
  end

  def video

    @video_data_param = params.require(:video_data).permit(:word)
    @word = @video_data_param["word"]

    
    url = "https://www.googleapis.com/youtube/v3/search?part=snippet&q="+ @word + "&key=" + DEVELOPER_KEY + "&maxResults=10"
    #日本語入力
    url = URI.escape(url)
    
    res = open(url)
    result = res.read
    video_response = JSON.parse(result)
    
    @video_result = ""
    
    video_response["items"].each do |row|
      if row["id"]["kind"].to_s.eql?("youtube#video") then
        @video_result += "<tr>"
        @video_result += "<td><a href='" + url_for(:controller => 'static_pages', :action => 'detail', :word => @word, :video => row["id"]["videoId"], :title => row["snippet"]["title"]) + "'><img src='" + row["snippet"]["thumbnails"]["medium"]["url"].to_s + "'/></td>"
        @video_result += "<td><h3>" + row["snippet"]["title"].to_s + "</h3><br/><font color='gray'>" + row["snippet"]["description"].to_s + "</font></td>"
        @video_result += "</tr>"
      end
    end
  end
  
  def detail
    @word = params["word"]
    @video_id = params["video"]
    @title = params["title"]
    @video_ch = params["video_ch"]
    @posts = Post.where(:video_id => @video_id)
    @post = Post.new
    session[:video_id] = @video_id
  end
  
  def create
    @post = Post.new(params.require(:post).permit(:video_id, :content))
    
    respond_to do |format|
      if @post.save
        format.html { redirect_to :action => "detail",:video => session[:video_id], notice: 'Post was successfully created.' }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

end
