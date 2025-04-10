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
              posts=JSON.parse(File.read('your_recently_followed_history.json'))
              posts["label_values"][0]["vec"].each do |post|
                groupname=post["dict"][0]["value"]
                p post["dict"][0]["label"]

                begin
                  browser.goto("https://facebook.com/search/top?q="+groupname)
                  browser.wait_until do |b|
                      b.text.include?("Suivi(e)") or b.text.include?("n'est pas disponible") or b.text.include?("isn't available right now")
                  end
                  next if browser.text.include?("n'est pas disponible") or browser.text.include?("isn't available right now")
                  browser.execute_script("document.querySelector(\"[aria-label='Suivi(e)']\").click()")
                  p "Toutes les photo"
                  browser.wait_until do |b|
                      b.text.include?("Toutes les photos")
                  end
                  browser.execute_script("document.querySelector(\"[aria-label*='Paramètres du profil voir plus d']\").click()")
                  browser.wait_until do |b|
                      b.text.include?("Suivi(e)")
                  end
                  browser.execute_script("document.querySelector(\"[role=menuitem]:last-child\").click()")
                  browser.wait_until do |b|
                      b.text.include?("Paramètres de suivi")
                  end
                  browser.execute_script("document.querySelector(\"[role=radio][aria-checked=false]\").outerHTML=''")
                  browser.execute_script("document.querySelector(\"[role=radio][aria-checked=false]\").click()")
                  browser.execute_script("document.querySelector(\"[aria-label='Mettre à jour']\").click()")
                     

                rescue => e
                  logger.info("\ngroup_id\nerreur \n "+e.message)
                  logger.error("\nil y a eu un probleme pour le group facebook  numero  "+groupname+" : "+e.message)
                  next
    
                end
              end
          end
      rescue => e
        logger.error("\nil y a eu un probleme pour la page de  "+link+" : "+e.message)
        next
    
      end
    
    
end
