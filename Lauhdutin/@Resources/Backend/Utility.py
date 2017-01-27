# Python environment
import string

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