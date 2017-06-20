# Python environment
import os, sqlite3, json
# Back-end
import Utility
from Enums import GameKeys
from Enums import Platform


class GOGGalaxy:
    def __init__(self, asPath):
        self.indexDB = os.path.join(asPath, "storage", "index.db")
        self.galaxyDB = os.path.join(asPath, "storage", "galaxy.db")
        self.productdetailsDB = os.path.join(asPath, "storage",
                                             "productdetails.db")
        self.result = {}
        self.index = {}
        self.galaxy = {}
        self.productdetails = {}
        self.values = []

    def set_result_entry(self, key, value):
        self.result[key] = value

    def result_has(self, key):
        if self.result.get(key, None) != None:
            return True
        return False

    def set_index_entry(self, key, value):
        self.index[key] = value

    def set_productdetails_entry(self, key, value):
        self.productdetails[key] = value

    def set_galaxy_entry(self, key, value):
        self.galaxy[key] = value

    def get_value(self):
        if len(self.values) > 0:
            return self.values.pop(0)
        return None

    def process_index_database(self):
        value = self.get_value()
        while value:
            print("\t\tFound game in '%s'" % value[3])
            self.set_result_entry(value[0], {})
            game = {}
            game[GameKeys.PLATFORM] = Platform.GOG_GALAXY
            game[GameKeys.LASTPLAYED] = 0
            game[GameKeys.PATH] = value[3]
            gameInfo = os.path.join(value[3], "goggame-%s.info" % value[0])
            if os.path.isfile(gameInfo):
                with open(gameInfo, encoding="utf-8") as f:
                    start = False
                    lines = f.readlines()
                    contents = ""
                    for line in lines:
                        if not start:
                            if line == "{\n":
                                start = True
                        if start:
                            contents = contents + line
                    contents = json.loads(contents)
                    game[GameKeys.PATH] = os.path.join(
                        game[GameKeys.PATH], contents["playTasks"][0]["path"])
            self.set_index_entry(value[0], game)
            value = self.get_value()

    def process_productdetails_database(self):
        value = self.get_value()
        while value:
            if self.result_has(value[0]):
                details = json.loads(value[3])
                game = {}
                game[GameKeys.NAME] = Utility.title_move_the(
                    Utility.title_strip_unicode(details["title"]))
                print("\t\tGetting info about '%s'" % game[GameKeys.NAME])
                banner_url = details["images"]["logo"].replace("\/", "/")
                banner_extension = banner_url[-4:]
                banner_url = banner_url[:-4]
                if banner_url.endswith("_196"):
                    banner_url = "%s_392%s" % (banner_url[:-4],
                                               banner_extension)
                elif banner_url.endswith("_glx_logo"):
                    banner_url = "%s_392%s" % (banner_url[:-9],
                                               banner_extension)
                game[GameKeys.BANNER_URL] = banner_url
                if not "http:" in game[GameKeys.BANNER_URL]:
                    game[GameKeys.BANNER_URL] = "http:" + game[
                        GameKeys.BANNER_URL]
                game[GameKeys.BANNER_PATH] = "GOG Galaxy\\" + value[0] + ".jpg"
                self.set_productdetails_entry(value[0], game)
            value = self.get_value()

    def process_galaxy_database(self):
        value = self.get_value()
        while value:
            if self.result_has(str(value[1])):
                images = json.loads(value[7])
                game = {}
                game[GameKeys.NAME] = Utility.title_move_the(
                    Utility.title_strip_unicode(value[5]))
                print("\t\tGetting info about '%s'" % game[GameKeys.NAME])
                banner_url = images["logo"].replace("\/", "/")
                banner_extension = banner_url[-4:]
                banner_url = banner_url[:-4]
                banner_url = "%s_392%s" % (banner_url[:-9],
                                           banner_extension)
                game[GameKeys.BANNER_URL] = banner_url
                game[GameKeys.BANNER_PATH] = "GOG Galaxy\\%s%s" % (value[1], banner_extension)
                self.set_galaxy_entry(str(value[1]), game)
            value = self.get_value()

    def get_games(self):
        self.result = {}
        self.index = {}
        self.productdetails = {}
        if not os.path.isfile(self.indexDB):
            print("\t'%s' does not exist..." % self.indexDB)
            return {}
        print("\tConnecting to 'index.db'...")
        con = sqlite3.connect(self.indexDB)
        cur = con.cursor()
        cur.execute("SELECT * FROM Products")
        self.values = cur.fetchall()
        con.close()
        self.process_index_database()
        for gameID, gameDict in self.index.items():
            for key, value in gameDict.items():
                self.result[gameID][key] = value
        if os.path.isfile(self.galaxyDB): # GOG Galaxy >= 1.2.x
            print("\tConnecting to 'galaxy.db'...")
            con = sqlite3.connect(self.galaxyDB)
            cur = con.cursor()
            cur.execute("SELECT * FROM LimitedDetails")
            self.values = cur.fetchall()
            con.close()
            self.process_galaxy_database()
            for gameID, gameDict in self.galaxy.items():
                for key, value in gameDict.items():
                    self.result[gameID][key] = value
        else: # GOG Galaxy < 1.2.x
            print("\t'%s' does not exist..." % self.galaxyDB)
            if os.path.isfile(self.productdetailsDB):
                print("\tConnecting to 'productdetails.db'...")
                con = sqlite3.connect(self.productdetailsDB)
                cur = con.cursor()
                cur.execute("SELECT * FROM ProductDetails")
                self.values = cur.fetchall()
                con.close()
                self.process_productdetails_database()
                for gameID, gameDict in self.productdetails.items():
                    for key, value in gameDict.items():
                        self.result[gameID][key] = value
            else:
                print("\t'%s' does not exist..." % self.productdetailsDB)
                return {}
        return self.result
