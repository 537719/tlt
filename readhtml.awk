#readhtml.awk
# d'après https://www.gnu.org/software/gawk/manual/gawkinet/html_node/Web-page.html#Web-page
BEGIN {
  RS = ORS = "\r\n"
  HttpService = "/inet/tcp/0/proxy/80"
  print "GET http://www.yahoo.com"     |& HttpService
  while ((HttpService |& getline) > 0)
     print $0
  close(HttpService)
}

