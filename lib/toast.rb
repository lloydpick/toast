#
# Toast - Automated Event Driver Twitter Ruby Library
# Written by Lloyd Pick
# http://gibhub.com/lloydpick
# May not be used for commercial applications without prior concent
#

# Requirements
require 'rubygems'
require 'sqlite3'
require 'fileutils'
require 'forwardable'
require 'httparty'
require 'mash'
require 'twitter'
require 'twitter/base'
require 'twitter/httpauth'

$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.dirname(__FILE__))

module Toast
  class TwitterAccount
    attr_accessor :username, :password

    def initialize(username = nil, password = nil)
      @username = username
      @password = password
    end
  end

  class Bread

    attr_accessor :name, :twitter_message, :twitter_account, :butters

    def initialize(name = nil, message = nil)
      @name = name
      @twitter_message = message
      @butters = []
    end

    class Butter < Bread

      attr_accessor :name, :post_condition, :function

      def initialize(name = nil, post_condition = nil, function = nil)
        @name = name
        @post_condition = post_condition
        @function = function
      end

    end

  end

  class Toaster

    attr_accessor :bread, :timer

    def initialize
      @bread = []
      @timer = 60
    end

    def toast!
      #File.delete("toast.db")
      db = SQLite3::Database.new("toast.db")
      db.execute("CREATE TABLE IF NOT EXISTS toasters (
                    id integer PRIMARY KEY,
                    frequency integer,
                    last_check datetime,
                    conditions varchar2(32),
                    complete integer
                );")
      db.execute("CREATE TABLE IF NOT EXISTS breads (
                    id integer PRIMARY KEY,
                    name varchar2(64),
                    twitter_username varchar2(64),
                    twitter_password varchar2(64),
                    twitter_message varchar2(140)
                );")
      db.execute("CREATE TABLE IF NOT EXISTS butters (
                    id integer PRIMARY KEY,
                    bread_id integer,
                    name varchar2(64),
                    function varchar2(64),
                    outcome varchar2(64)
                );")

      self.bread.each do |bread|
        db.execute("INSERT INTO breads (
                      name, 
                      twitter_username, 
                      twitter_password, 
                      twitter_message
                    ) VALUES (
                      :name,
                      :twitter_username,
                      :twitter_password,
                      :twitter_message
                    )
                  ",
                    "name" => bread.name,
                    "twitter_username" => bread.twitter_account.username,
                    "twitter_password" => bread.twitter_account.password,
                    "twitter_message" => bread.twitter_message
                  );
        bread_id = db.execute("select last_insert_rowid()")

        butters = []
        bread.butters.each do |butter|
          db.execute("INSERT INTO butters (
              bread_id,
              name,
              function,
              outcome
            ) VALUES (
              :bread_id,
              :name,
              :function,
              :outcome
            )
          ",
            "bread_id" => bread_id,
            "name" => butter.name,
            "function" => butter.function,
            "outcome" => butter.post_condition
          );
          butters << db.execute("select last_insert_rowid()")
        end

        db.execute("INSERT INTO toasters (
              frequency,
              conditions,
              complete,
              last_check
            ) VALUES (
              :frequency,
              :conditions,
              :complete,
              :last_check
            )
          ",
            "frequency" => self.timer,
            "conditions" => butters.join(","),
            "complete" => 0,
            "last_check" => Time.now
          );
        
      end

    end

    def self.run
      db = SQLite3::Database.new("toast.db")

      db.results_as_hash = true
      db.execute("select * from toasters where complete = 0") do |row|
        if ((Time.parse(row["last_check"]) + row["frequency"].to_i) < Time.now)
          row["conditions"].split(",")
          row["conditions"].each do |condition|
            db.execute("select * from butters where id = :id", ":id" => condition) do |butter_row|
              output = eval(butter_row["function"])
              if output == butter_row["outcome"]
                db.execute("select * from breads where id = :id", ":id" => butter_row["bread_id"]) do |twitter|
                  httpauth = Twitter::HTTPAuth.new(twitter["twitter_username"], twitter["twitter_password"])
                  base = Twitter::Base.new(httpauth)
                  base.update(twitter["twitter_message"])
                  db.execute("update toasters set complete = \"1\" where id = :id;", "id" => row["id"])
                end
              else
                # Did'nt pass the condition, so update the time
                db.execute("update toasters set last_check = :lastcheck where id = :id",
                          "lastcheck" => Time.now, "id" => row["id"])
              end
            end
          end
        end
      end
    end

  end
  
end