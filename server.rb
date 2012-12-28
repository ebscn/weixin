# encoding: utf-8
#load the files
$:.push File.expand_path("../lib", __FILE__)


require 'sinatra'
require 'active_support/all'
require 'digest/md5'
require 'rexml/document'
require "date"
require 'debugger'
require 'data_mapper' # requires all the gems listed above

require 'config'


require './models/article'
require './models/location_message'
require './models/news_message'
require './models/picture_message'
require './models/text_message'

DataMapper.setup(:default, "sqlite3:./db/fumutang.db")
DataMapper.finalize
DataMapper.auto_upgrade!

WeiXin::Config.token = "weixin"
WeiXin::Config.url = "http://weixin.bbtang.com"

class Server < Sinatra::Application
  #token, timestamp, nonce
  def geneate_signature(token,timestamp,nonce)
    signature = [token.to_s,timestamp.to_s,nonce.to_s].sort.join("")
    Digest::SHA1.hexdigest(signature)
  end

  def valid_signature?(signature,timestamp,nonce)
    token = WeiXin::Config.token

    if signature.present? and token.present? and timestamp.present? and nonce.present?
      guess_signature = geneate_signature(token,timestamp,nonce)
      guess_signature.eql? signature
    end
  end

  #http://www.ruby-doc.org/stdlib-1.9.3/libdoc/rexml/rdoc/REXML.html
  #http://www.germane-software.com/software/rexml/docs/tutorial.html
  #==========xml generate

  #
=begin
* signature — 微信加密签名
* timestamp — 时间戳
* nonce — 随机数
* echostr — 随机字符串
=end
  #params
  def present?(val)
    !val.nil? and !val.empty?
  end

  #curl http://localhost:4567/?nonce=121212121&signature=f3739ef63eaeaafc6e935ab9202f6e0e4bee2c03&timestamp=1356601689&echostr=22222222222222222
  get '/' do
    #token= params[:token]
    if valid_signature?(signature= params[:signature], timestamp = params[:timestamp], nonce= params[:nonce] )
      logger.info("signature is ok and return #{params[:echostr]}")
      puts "signature is ok and return #{params[:echostr]}"
      params[:echostr]
    end
  end

  post '/' do
    #puts Hash.from_xml params
    puts params
    request.body.rewind  # in case someone already read it
    data = JSON.parse request.body.read
  end
end
