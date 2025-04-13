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

              #browser.execute_script("alert('hey anonyme');return false") # Open the rest in new tabs
              logger.info("\nhey !!! \nje suis sur un compte anonyme \n ")
              posts=JSON.parse(File.read('posts.json'))
              posts["data"].each do |post|
                begin
                  browser.goto("https://facebook.com/"+post["id"])
                  browser.wait_until(timeout: 10) do |b|
                      debutmsg= post["message"].encode("utf-8")
                      p "LE MESSAGE EST AFFICHE OU PAS:"+b.text.include?(debutmsg).to_s
                      b.text.include?("Ce contenu n’est pas disponible pour le moment") or b.text.include?("This content isn't available right now") or b.text.include?(debutmsg)  or b.text.include?("Modifier")
                  end
                  next if browser.text.include?("contenu n'est pas disponible")

                  next if browser.text.include?("isn't available right now")
                     
                  browser.execute_script("document.querySelector(\"[aria-label='Actions pour cette publication'][aria-expanded='false']\").click()")
                  browser.execute_script("document.querySelector(\"[aria-label='Actions pour cette publication'][aria-expanded='false']\").click()")
                  logger.info("\nclick actions \n ")

                  browser.wait_until do |b|
                      b.text.include?("Supprimer la")
                  end
                  if browser.text.include?("Supprimer la photo")
                      browser.execute_script("document.querySelector(\"[role='menuitem']:nth-child(6)\").click()")
                  else

                      browser.execute_script("document.querySelector(\"[role='menuitem']:nth-child(5)\").click()")

                  end
                  logger.info("\ndemander supprime \n ")
                  browser.wait_until{|b|b.text.include?("Supprimer") or b.text.include?("Votre publication pourra apparaître dans le fil d’actualité, sur votre profil, dans les résultats de recherche et sur Messenger.")}
                  if browser.text.include?("Supprimer")
                      browser.execute_script("document.querySelector('[aria-label=Supprimer]').click()")
                  else
                      browser.execute_script("document.querySelector(\"[aria-label='Terminé']\").click()")
                      browser.wait_until(timeout: 10) do |b|
                          b.text.include?(debutmsg)
                      end
                      browser.execute_script("document.querySelector(\"[aria-label='Actions pour cette publication'][aria-expanded='false']\").click()")
                      logger.info("\nclick actions \n ")

                      browser.wait_until do |b|
                          b.text.include?("Supprimer la")
                      end
                      browser.execute_script("document.querySelector(\"[role='menuitem']:nth-child(5)\").click()")
                      browser.wait_until do |b|
                          b.text.include?("Supprimer définitivement la publication")
                      end
                      browser.execute_script("document.querySelector('[role=menu]').outerHTML=''")
                      browser.execute_script("document.querySelector(\"[role=menuitem]:nth-last-child(4)\").click()")
                  end
                  logger.info("\nsupprime \n ")



                rescue => e
                  logger.info("\npost_id"+post["id"]+"\nerreur \n "+e.message)
                  logger.error("\nil y a eu un probleme pour le post facebook  numero  "+post["id"]+" : "+e.message)
                  next
    
                end
              end
          end
      rescue => e
        logger.error("\nil y a eu un probleme pour la page de  "+link+" : "+e.message)
        next
    
      end
    
    
end
