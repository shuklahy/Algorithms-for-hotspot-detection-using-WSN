n1 = open('Grp2','w')
n2 = open('Grp3','w')

c1 = c2 = 1
g2 = False
g3 = False
with open('smart pinging with groups', 'r') as f:
  lineArr=f.read().split('\n')
  for a in lineArr:
	if(g2):
		g2 = False
		n1.write(str(c1)+'  '+a+'\n')
		c1 = c1 + 1	
	if(g3):
		g3 = False
		n2.write(str(c2)+'  '+a+'\n')
		c2 = c2 + 1	
			
	
	if 'POLL REPLY: Gid 2' in a:
		g2 = True
		
	if 'POLL REPLY: Gid 3' in a:
		g3 = True
	
n1.close()
n2.close()

