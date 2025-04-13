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
                monlien="https://www.facebook.com/#{ENV["YOURID"]}/allactivity?activity_history=false&category_key=YOURACTIVITYPOSTSSCHEMA&manage_mode=false&should_load_landing_page=false"
                browser.goto(monlien)
                browser.wait_until do |b|
                    b.text.include?("Publications")
                end
                while browser.text.include?("a mis à jour") do
                    while browser.text.include?("a mis à jour") do
                        browser.execute_script("document.querySelector(\"[aria-label='Options d’action']\").click()")
                        browser.wait_until do |b|
                            b.text.include?("Déplacer dans la corbeille") or b.text.include?("Ajouter au profil")
                        end
                        if browser.text.include?("Ajouter au profil")
                            browser.execute_script("document.querySelector(\"[role=menuitem]:nth-child(1)\").click()")
                        else
                            browser.execute_script("document.querySelector(\"[role=menuitem]:nth-last-child(1)\").click()")
                            browser.wait_until do |b|
                                b.text.include?("Les éléments déplacés dans la corbeille seront supprimés après 30 jours.")
                            end
                            browser.execute_script("document.querySelector(\"[aria-label='Déplacer dans la corbeille'][role=button]\").click()")
                        end

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
