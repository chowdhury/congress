from BeautifulSoup import BeautifulStoneSoup
import re
import urllib2
import datetime, time
import rtc_utils
import HTMLParser


def run(db, es, options = {}):
    try:
      page = urllib2.urlopen("http://www.senate.gov/general/committee_schedules/hearings.xml")
    except:
      db.note("Couldn't load Senate hearings feed, can't proceed")
      
    else:
      soup = BeautifulStoneSoup(page)
      meetings = soup.findAll('meeting')
      parser = HTMLParser.HTMLParser()
      
      count = 0
      
      for meeting in meetings:
          if re.search("^No.*?scheduled\.?$", meeting.matter.contents[0]):
            continue
            
          full_id = meeting.cmte_code.contents[0].strip()
          committee_id, subcommittee_id = re.search("^([A-Z]+)(\d+)$", full_id).groups()
          if subcommittee_id == "00": 
            subcommittee_id = None
          else:
            subcommittee_id = full_id
          
          committee = committee_for(db, committee_id)
          

          # Don't warn if it's a bill-specific conference committee
          if not committee and committee_id != "JCC":
            db.warning("Couldn't locate committee by committee_id %s" % committee_id, {'committee_id': committee_id})
          
          committee_url = meeting.committee['url']

          date_string = meeting.date.contents[0].strip()
          occurs_at = datetime.datetime(*time.strptime(date_string, "%d-%b-%Y %I:%M %p")[0:6], tzinfo=rtc_utils.EST())
          congress = rtc_utils.current_congress(occurs_at.year)
          
          document = None
          if meeting.document:
            document = meeting.document.contents[0].strip()
              
          room = meeting.room.contents[0].strip()
          description = meeting.matter.contents[0].strip().replace('\n', '')

          # content is double-escaped, e.g. &amp;quot;
          description = parser.unescape(parser.unescape(description))

          bill_ids = rtc_utils.extract_bills(description, congress)
          

          documents = db['hearings'].find({
            'chamber': 'senate', 
            'committee_id': committee_id, 
              
            "$or": [{
              'occurs_at': occurs_at
              },{
              'description': description
            }]
          })

          hearing = None
          if documents.count() > 0:
            hearing = documents[0]
          else:
            hearing = {
              'chamber': 'senate', 
              'committee_id': committee_id
            }

            hearing['created_at'] = datetime.datetime.now()
          
          if subcommittee_id:
            hearing['subcommittee_id'] = subcommittee_id
          hearing['updated_at'] = datetime.datetime.now()
          
          hearing.update({
            'congress': congress,
            'occurs_at': occurs_at,
            'room': room, 

            'description': description, 
            'dc': True,

            'bill_ids': bill_ids
          })
          
          if committee:
            hearing['committee'] = committee
          
          db['hearings'].save(hearing)
          
          count += 1
      
      db.success("Updated or created %s Senate committee hearings" % count)

def committee_for(db, committee_id):
  committee = db['committees'].find_one({'committee_id': committee_id}, fields=["committee_id", "name", "chamber"])
  if committee:
    del committee['_id']
  return committee