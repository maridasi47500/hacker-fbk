require 'watir'
require 'addressable/uri'
require 'i18n'
require 'json'
require 'date'
require 'logger'
require "rails"
@d=JSON.parse(File.read("out.json"))


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
              monlien="https://www.facebook.com/messages/t/#{ENV["YOURID"]}"
              logger.info("\n#{monlien}  \n ")

              browser.goto(monlien)


              100.times do
                  begin



                      logger.info("\nje suis bien  arrivee a #{browser.url}  \n ")
                      browser.wait_until do |b|
                          b.text.include?("Discussions")
                      end
                      begin

                          browser.execute_script("document.querySelector(\"[aria-label*='Autres options pour']\").click()")
                      rescue => e
                          logger.info("\n erreur supprimer discussion  1")
                      end
                      browser.wait_until do |b|
                          b.text.include?("Supprimer la discussion")
                      end
                      browser.execute_script("document.querySelector(\"[role=menuitem]:nth-last-child(2)\").click()")
                      logger.info("\n retirer")

                      browser.wait_until do |b|
                          b.text.include?("La suppression de votre copie de cette conversation est irréversible.") or b.text.include?("Nous utilisons vos commentaires pour nous aider à reconnaître les situations anormales.")

                      end
                      if browser.text.include?("Nous utilisons vos commentaires pour nous aider à reconnaître les situations anormales.")
                          browser.execute_script("document.querySelector(\"[aria-label='Fermer'][role=button]\").click()")
                          begin

                              browser.execute_script("document.querySelector(\"[aria-label*='Autres options pour']\").click()")
                          rescue => e
                              logger.info("\n erreur supprimer discussion  1")
                          end
                          browser.wait_until do |b|
                              b.text.include?("Supprimer la discussion")
                          end
                          browser.execute_script("document.querySelector(\"[role=menuitem]:nth-last-child(3)\").click()")
                          browser.wait_until do |b|
                              b.text.include?("La suppression de votre copie de cette conversation est irréversible.")

                          end
                          logger.info("\n retirer")
                      end
                      browser.execute_script("document.querySelector(\"[aria-label='Supprimer la discussion'][role=button]\").outerHTML=''")
                      browser.execute_script("document.querySelector(\"[aria-label='Supprimer la discussion'][role=button]\").click()")
                      logger.info("\n retirer valider")


                       

                  rescue => e
                    logger.info("\ngroup_id\nerreur \n "+e.message.to_s)
                    logger.error("\nil y a eu un probleme pour le group facebook  avec le message: "+e.message.to_s)
                    next
    
                  end
              end
          end
          browser.execute_script("alert('finish les messages sont supprime')")
      rescue => e
        logger.error("\nil y a eu un probleme pour la page de  "+link+" : "+e.message)
        next
    
      end
    
    
end
