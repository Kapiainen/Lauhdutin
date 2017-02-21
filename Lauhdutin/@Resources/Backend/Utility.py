# Python environment
import string, os


def title_strip_unicode(asTitle):
    title = ""
    for char in asTitle:
        if char in string.printable:
            title = title + char
    return title


def title_move_the(asTitle):
    title = asTitle
    if title.lower()[:4] == "the ":
        title = title[4:] + ", " + title[:3]
    return title


def get_os_bitness():
    if (os.environ["PROCESSOR_ARCHITECTURE"][-2:] == "86" and
            os.environ.get("PROCESSOR_ARCHITEW6432", None) == None):
        return 32
    return 64
