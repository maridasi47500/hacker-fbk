require 'watir'
require 'addressable/uri'
require 'i18n'
require 'json'
require 'date'
require 'logger'
require "rails"
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
                Dir.glob("./inbox/*")[1..].each_with_index do |w,z|
                    logger.info("\nhello  \ncomment vas tu ?  \n ")
                    logger.info("\ncest une string?  \n ")
                    logger.info("\n#{w.is_a?(String)}  \n ")
                    x=w.gsub("./inbox/","")
                    logger.info("\ncest une string?  \n ")
                    logger.info("\n#{x.is_a?(String)}  \n ")
                    x=x.split("_")
                    logger.info("\nwow !!! \n#{z}ieme contact  \n ")
                    numero=x[1]
                    monlien="https://www.facebook.com/messages/t/#{numero}"
                    logger.info("\n#{monlien}  \n ")

                    browser.goto(monlien)
                    logger.info("\n#{Dir.glob(w+"/*").length} groupes de messages pour supprimer \n ")
                    logger.info("\nje suis bien  arrivee a #{browser.url}  \n ")
                    Dir.glob(w+"/*").each do |yeah|
                        begin
                            logger.info("\n====================my list of messages is a string====================")
                            logger.info("\n #{yeah.is_a?(String)}")

                            msg=JSON.parse(File.read(yeah))
                            logger.info("\n====================participants de cette idscusion====================")
                            logger.info("\n"+msg["participants"].map {|p|p["name"][0..2]+"$$$$ANONYME"}.to_sentence)
                            
                            browser.wait_until do |b|
                                b.text.include?(msg["participants"][1]["name"]) and b.text.include?(msg["participants"][0]["name"]) and msg["messages"].any? {|mymsg|b.text.include?(mymsg["content"].encode("utf-8")) }
                            end
                            while msg["messages"].any? {|mymsg|browser.text.include?(mymsg["content"].encode("utf-8")) }
                                nbmsg= msg["messages"].count {|mymsg|browser.text.include?(mymsg["content"].encode("utf-8")) }
                                logger.info("\nnot finish yet : il y a encore #{nbmsg} msg non supprime sur la page")
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
                                logger.info("\nmessage "+i.to_s)

                            end
                        rescue => e
                            logger.error("\n "+e.message.to_s)
                        end
                    end
                end
                browser.execute_script("alert('finish les messages sont supprime')")
                   

              rescue => e
                logger.info("\ngroup_id\nerreur \n "+e.message.to_s)
                logger.error("\nil y a eu un probleme pour le group facebook  avec le message: "+e.message.to_s)
                next
    
              end
          end
      rescue => e
        logger.error("\nil y a eu un probleme pour la page de  "+link+" : "+e.message)
        next
    
      end
    
    
end
