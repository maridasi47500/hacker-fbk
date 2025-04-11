require 'watir'
require 'addressable/uri'
require 'i18n'
require 'json'
require 'date'
require 'logger'
def okurl(ok)
    return Addressable::URI.escape(ok)
end

d = DateTime.now
Watir.default_timeout = 30 


                          #=> #<DateTime: 2007-11-19T08:37:48-0600 ...>
mytime=d.strftime("%m%d%Y%I%M%p")
logger = Logger.new('logs/app'+mytime+'.log', 3, 10 * 1024 * 1024)


I18n.load_path += Dir[File.expand_path("locales") + "/*.yml"]
I18n.default_locale = :fr # (note that `en` is already the default!)
wow=Date.today



links = ["https://www.facebook.com"]
links.to_a.each do |link|
      begin
          if link.include?("facebook")
              browser = Watir::Browser.new :firefox
              browser.goto(link)
              browser.wait_until {|x| x.title != "Facebook - log in or sign up" }

              logger.info("\nhey !!! \nje suis sur un compte anonyme \n ")

              begin
                monlien="https://www.facebook.com/#{ENV["FBUSERNAME"]}/allactivity/?activity_history=false&category_key=YOURACTIVITYCOMMENTSANDREACTIONSSCHEMA&manage_mode=false&should_load_landing_page=false"
                browser.goto(monlien)
                browser.wait_until do |b|
                    b.text.include?("Commentaires et réactions")
                end
                while browser.text.include?("a aimé") or browser.text.include?("a commenté") do
                    while browser.text.include?("a aimé") or browser.text.include?("a commenté") do
                        browser.execute_script("document.querySelector(\"[aria-label='Options d’action']\").click()")
                        browser.wait_until do |b|
                            b.text.include?("Supprimer") or b.text.include?("Je n’aime plus")
                        end
                        browser.execute_script("document.querySelector(\"[role=menuitem]:nth-child(1)\").click()")
                    end
                    browser.goto(monlien)
                end
                browser.execute_script("alert('finish les likes sont supprimes')")
                   

              rescue => e
                logger.info("\ngroup_id\nerreur \n "+e.message.to_s)
                logger.error("\nil y a eu un probleme pour le group facebook  numero  "+groupname+" : "+e.message)
                next
    
              end
          end
      rescue => e
        logger.error("\nil y a eu un probleme pour la page de  "+link+" : "+e.message)
        next
    
      end
    
    
end
