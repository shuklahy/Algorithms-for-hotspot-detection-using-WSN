n1 = open('node2','w')
n2 = open('node3','w')
n3 = open('node4','w')
n4 = open('node5','w')
n5 = open('node6','w')
n6 = open('node7','w') 

c1 = c2 = c3 = c4 = c5 = c6 = 1

with open('Simple Algorithm', 'r') as f:
  lineArr=f.read().split('\n')
  for a in lineArr:
	if 'Node: 2' in a:
		n1.write(str(c1)+'  '+a+'\n')
		c1 = c1 + 1
	if 'Node: 3' in a:
		n2.write(str(c2)+'  '+a+'\n')
		c2 = c2 + 1
	if 'Node: 4' in a:
		n3.write(str(c3)+'  '+a+'\n')
		c3 = c3 + 1
	if 'Node: 5' in a:
		n4.write(str(c4)+'  '+a+'\n')
		c4 = c4 + 1
	if 'Node: 6' in a:
		n5.write(str(c5)+'  '+a+'\n')
		c5 = c5 + 1
	if 'Node: 7' in a:
		n6.write(str(c6)+'  '+a+'\n')
		c6 = c6 + 1

n1.close()
n2.close()
n3.close()
n4.close()
n5.close()
n6.close()

