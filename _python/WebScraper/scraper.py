from bs4 import BeautifulSoup
import csv
import unidecode
import re
import cloudscraper

scraper = cloudscraper.create_scraper() 
url_base = "https://www.2kratings.com/teams/"

contractInfo = []
teams = ["philadelphia-76ers", "milwaukee-bucks", "chicago-bulls", "charlotte-hornets", "new-york-knicks", "miami-heat", "washington-wizards", "atlanta-hawks", 
            "brooklyn-nets", "cleveland-cavaliers", "boston-celtics", "toronto-raptors", "orlando-magic", "indiana-pacers", "detroit-pistons", "golden-state-warriors",
            "utah-jazz", "memphis-grizzlies", "denver-nuggets", "minnesota-timberwolves", "dallas-mavericks", "los-angeles-clippers", "sacramento-kings", "phoenix-suns",
            "houston-rockets", "san-antonio-spurs", "portland-trail-blazers", "los-angeles-lakers", "new-orleans-pelicans", "oklahoma-city-thunder"]

stats = ["Ball Handle", "Close Shot", "Mid-Range Shot", "Three-Point Shot", "Layup", "Steal", "Block", "Interior Defense", 
            "Perimeter Defense", "Speed", "Stamina", "Pass Accuracy", "Speed with Ball", "Lateral Quickness", "Pass Perception",
            "Strength", "Potential"]

def findContractInfo(player):
    for contract in contractInfo:
        if(contract["name"] in player or player in contract["name"]):
            return contract
    
    return {"name": "", "contractValue": 1000000, "contractLength": 1}


with open('data/contracts.csv', newline='') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',', quotechar='|')

    for row in spamreader:
        contractInfo.append({"name": row[0], "contractValue": row[1], "contractLength": row[2]})

for team in teams:
    with open('data/' + team + '.csv', 'w', newline='') as csvfile:
        print()
        print(team)
        spamwriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        #page = requests.get(url_base + team)
        page = scraper.get(url_base + team).text
        teamPage = BeautifulSoup(page, "html.parser")

        playerLabel = teamPage.find("th", string="Player")
        playerTable = playerLabel.parent.parent.parent
        players = playerTable.find_all("a")

        numPlayers = 0
        for player in players:
            if(numPlayers >= 15):
                break

            if(player.has_attr("title") and "2k" in player["href"]):
                numPlayers += 1
                name = player.text
                nameParts = name.split(" ")
                nameToLook = nameParts[0] + " " + nameParts[1]
                nameToLook = unidecode.unidecode(nameToLook)
                print(nameToLook)
                # 1: Name, 2: Dribbling, 3: CloseShot, 4: MidRange, 5: Three, 6: Finishing, 7: Stealing, 8: Blocking, 9: ContestingInterior, 10: ContestingExterior,
                #       11: Speed, 12: Stamina, 13: Passing, 14: Height, 15: Number
                playerAttrs = []
                playerAttrs.append(nameToLook)

                #page2 = requests.get(player["href"])
                page2 = scraper.get(player["href"]).text
                playerPage = BeautifulSoup(page2, "html.parser")
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
                number = 0
                heightElement = playerPage.find(text=lambda t: "Height:" in t).parent
                numberElement = playerPage.find(text=lambda t: "Jersey: #" in t)
                yearsElement = playerPage.find(text=lambda t: "Year(s) in the NBA:" in t)

                height = heightElement.find("span").text.split(" ")[0]

                if numberElement:
                    numberStr = numberElement.split("#")[1]
                    number = int(numberStr)

                years = 1
                if(yearsElement):
                    yearsStr = yearsElement.split(": ")[1]
                    years = int(yearsStr)
                
                heightParts = re.split("'|\"", height)
                heightInInches = int(heightParts[0]) * 12 + int(heightParts[1])
                heightValue = heightInInches - 74
                if heightValue < 1:
                    heightValue = 1
                elif heightValue > 10:
                    heightValue = 10
                
                playerAttrs.append(heightValue)
                playerAttrs.append(number)
                playerAttrs.append(years)

                # Get Contract Values
                contract = findContractInfo(nameToLook)
                playerAttrs.append(contract["contractValue"])
                playerAttrs.append(contract["contractLength"])

                spamwriter.writerow(playerAttrs)

