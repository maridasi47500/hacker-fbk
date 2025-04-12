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
                monlien="https://www.facebook.com/messages/t/386155821439928"
                browser.goto(monlien)
                browser.wait_until do |b|
                    b.text.include?("titre personne") and b.text.include?("premier message")
                end
                div1="bonjour1"

                browser.execute_script("document.querySelector(\"[role=presentation] > span[dir=auto]\").parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.id='#{div1}'")
                browser.element(id: div1).fire_event(:mouseover)
                browser.execute_script("document.querySelector(\"[aria-label='Plus']\").click()")
                browser.wait_until do |b|
                    b.text.include?("Retirer")
                end
                browser.execute_script("document.querySelector(\"[aria-label='Supprimer le message']\").click()")
                browser.wait_until do |b|
                    b.text.include?("Pour qui voulez-vous retirer ce message ?")
                end
                browser.execute_script("document.querySelector(\"[aria-label='Retirer']\").outerHTML=''")
                browser.execute_script("document.querySelector(\"[aria-label='Retirer']\").click()")
                n=false
                browser.execute_script("alert('finish le message est supprime')")
                #browser.execute_script("alert('finish les likes sont supprimes')")
                   

              rescue => e
                logger.info("\ngroup_id\nerreur \n "+e.message)
                logger.error("\nil y a eu un probleme pour le group facebook  avec le message: "+e.message)
                next
    
              end
          end
      rescue => e
        logger.error("\nil y a eu un probleme pour la page de  "+link+" : "+e.message)
        next
    
      end
    
    
end
