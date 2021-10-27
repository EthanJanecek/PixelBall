import requests
from bs4 import BeautifulSoup
import csv
import unidecode

url_base = "https://www.2kratings.com/teams/"

teams = ["philadelphia-76ers", "milwaukee-bucks", "chicago-bulls", "charlotte-hornets", "new-york-knicks", "miami-heat", "washington-wizards", "atlanta-hawks", 
            "brooklyn-nets", "cleveland-cavaliers", "boston-celtics", "toronto-raptors", "orlando-magic", "indiana-pacers", "detroit-pistons", "golden-state-warriors",
            "utah-jazz", "memphis-grizzlies", "denver-nuggets", "minnesota-timberwolves", "dallas-mavericks", "los-angeles-clippers", "sacramento-kings", "phoenix-suns",
            "houston-rockets", "san-antonio-spurs", "portland-trail-blazers", "los-angeles-lakers", "new-orleans-pelicans", "oklahoma-city-thunder"]

stats = ["Ball Handle", "Close Shot", "Mid-Range Shot", "Three-Point Shot", "Layup", "Steal", "Block", "Interior Defense", "Perimeter Defense", "Speed", 
            "Stamina", "Pass Accuracy"]

allPlayersPage = requests.get("https://basketball.realgm.com/nba/players")
allPlayers = BeautifulSoup(allPlayersPage.content, "html.parser")
playerDiv = allPlayers.find("div", class_="main-container")

for team in teams:
    with open('_python/WebScraper/data/' + team + '.csv', 'w', newline='') as csvfile:
        print()
        print(team)
        spamwriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        page = requests.get(url_base + team)
        teamPage = BeautifulSoup(page.content, "html.parser")

        playerLabel = teamPage.find("th", string="Player")
        playerTable = playerLabel.parent.parent.parent
        players = playerTable.find_all("a")

        for player in players:
            if(player.has_attr("title") and "2k" in player["href"]):
                name = player.text
                nameParts = name.split(" ")
                nameToLook = nameParts[0] + " " + nameParts[1]
                nameToLook = unidecode.unidecode(nameToLook)
                print(nameToLook)
                # 1: Name, 2: Dribbling, 3: CloseShot, 4: MidRange, 5: Three, 6: Finishing, 7: Stealing, 8: Blocking, 9: ContestingInterior, 10: ContestingExterior,
                #       11: Speed, 12: Stamina, 13: Passing, 14: Height, 15: Number
                playerAttrs = []
                playerAttrs.append(nameToLook)

                page2 = requests.get(player["href"])
                playerPage = BeautifulSoup(page2.content, "html.parser")
                statsDiv = playerPage.find(id="nav-attributes")

                for stat in stats:
                    statElement = statsDiv.find(text=lambda t: stat in t)
                    span = statElement.parent.find("span")
                    statValue = int(span.text)

                    scaledValue = round((statValue - 50) / 5.0)
                    if scaledValue < 1:
                        scaledValue = 1
                    elif scaledValue > 10:
                        scaledValue = 10

                    playerAttrs.append(scaledValue)
        
                # Get height and number
                nameElement = playerDiv.find(text=lambda t: nameToLook in t)
                height = "1-1"
                number = -1

                if(nameElement):
                    children = nameElement.parent.parent.parent.find_all("td")
                    height = children[3].text
                    number = int(children[0].text)
                
                heightParts = height.split("-")
                heightInInches = int(heightParts[0]) * 12 + int(heightParts[1])
                heightValue = heightInInches - 74
                if heightValue < 1:
                    heightValue = 1
                elif heightValue > 10:
                    heightValue = 10
                
                playerAttrs.append(heightValue)
                playerAttrs.append(number)
                spamwriter.writerow(playerAttrs)

