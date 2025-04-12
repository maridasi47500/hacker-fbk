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
                Dir.glob("./inbox/*")[1..].each do |w|
                    x=w.gsub("./inbox/","").split["_"]
                    numero=x[1]
                    monlien="https://www.facebook.com/messages/t/#{numero}"

                    browser.goto(monlien)
                    msg=JSON.parse(Dir.glob(w+"/*")[0])
                    
                    browser.wait_until do |b|
                        b.text.include?(msg["participants"][1]["name"]) and b.text.include?(msg["participants"][0]["name"]) and b.text.include?(msg["messages"][0]["content"])
                    end
                    msg["messages"].each_with_index do |k,i|
                        div1="bonjour#{i}"

                        browser.execute_script("document.querySelector(\"[role=presentation] > span[dir=auto]\").parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.id='#{div1}'")
                        browser.element(id: div1).fire_event(:mouseover)
                        browser.execute_script("document.querySelector(\"[aria-label='Plus']\").click()")
                        browser.wait_until do |b|
                            b.text.include?("Retirer")
                        end
                        browser.execute_script("document.querySelector(\"[aria-label='Supprimer le message']\").click()")
                        browser.wait_until do |b|
                            b.text.include?("Pour qui voulez-vous retirer ce message ?") or b.text.include?("Supprimer pour vous") or b.text.include?("Supprimer pour tout le monde")
                        end
                        browser.execute_script("document.querySelector(\"[aria-label='Retirer']\").outerHTML=''")
                        browser.execute_script("document.querySelector(\"[aria-label='Retirer']\").click()")
                        n=false
                        browser.execute_script("alert('finish le message est supprime')")
                    end
                end
                   

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
