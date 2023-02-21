from bs4 import BeautifulSoup
import cloudscraper
import csv
import unidecode

scraper = cloudscraper.create_scraper() 
contract_url = "https://www.spotrac.com/nba/"
contractInfo = []
year = 2022

def getContractInfo():
    with open('data/contracts.csv', 'w', newline='') as csvfile:
        spamwriter = csv.writer(csvfile, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
        page1 = scraper.get(contract_url).text
        allPage = BeautifulSoup(page1, "html.parser")

        teamLabel = allPage.find("div", class_="teamlist")
        teamTable = teamLabel.find_all("a", class_="team-name")
        
        for team in teamTable:
            page2 = scraper.get(team["href"]).text
            teamPage = BeautifulSoup(page2, "html.parser")

            posLabel = teamPage.find("th", string="Pos.")
            playerLabel = posLabel.parent.parent.parent
            playerTable = playerLabel.find_all("td", class_="player")

            for player in playerTable:
                playerVal = player.find("a")
                page3 = scraper.get(playerVal["href"]).text
                playerPage = BeautifulSoup(page3, "html.parser")

                playerName = unidecode.unidecode(playerVal.text)

                playerSalaryTag = playerPage.find("span", string="Avg. Salary:").parent
                playerSalaryValue = playerSalaryTag.find("span", class_="playerValue").text
                playerSalary = int(playerSalaryValue.replace(",", "")[1:])

                playerContractEndTag = playerPage.find("span", string="Free Agent:").parent
                playerContractEndValue = playerContractEndTag.find("span", class_="playerValue").text
                playerContractEnd = int(playerContractEndValue.split(" / ")[0]) - year

                spamwriter.writerow([playerName, playerSalary, playerContractEnd])
                print(playerName + ", " + str(playerSalary) + ", " + str(playerContractEnd))
            

getContractInfo()
