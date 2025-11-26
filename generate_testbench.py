import sys

module = 'our'
if len(sys.argv)>1:
	module = sys.argv[1]
start = 0
if len(sys.argv)>2:
	start = int(sys.argv[2])
end = 20000
if len(sys.argv)>3:
	end = int(sys.argv[3])

with open('test.vcd', 'r') as f:
    lines = f.readlines()

module_list = module.split('_')[:-1]
st = module_list[0]
for i in range(1,len(module_list)):
	st+='_'+module_list[i]

with open(st+'.sv','r') as f:
	module_lines = f.readlines()

mp = dict()
mp_ver = dict()
last = ''
cnt = 0

while len(lines[cnt])>1:
	line = lines[cnt]
	words = line.strip().split()
	if len(words)==0:
		continue

	if words[0] == '$scope':
		last = words[2]
	if words[0] == '$var':
		if last==module:
			mp_ver[words[4]]=list()
			mp_ver[words[4]].append(words[2])
			mp[words[3]] = list()
			mp[words[3]].append(words[4])
			mp[words[3]].append(list())
			mp[words[3]][1].append(last)
	cnt+=1

cnt+=2

for i in module_lines:
	if ('output' in i.split(' ')) or ('input' in i.split(' ')):
		st_var = i.split(' ')[-1][:-1]
		if ',' in st_var:
			st_var = st_var[:-1]
		for j in mp_ver:
			if j == st_var:
				mp_ver[j].append('inout')
				break

mp_ver_tmp = list(mp_ver.keys())
for i in mp_ver_tmp:
	if len(mp_ver[i])<2:
		del mp_ver[i]


while True:
	line = lines[cnt]
	cnt+=1
	if line[0] == '#' and int(line[1:])>=start:
		break

cntr = 0
f = open('testbench.sv', 'w')
f_module = module[:-2]+' '+module+'(\n'
f_logic = ''
f_if = ''
for i in mp_ver:
	cntr += 1
	s = f'logic [{mp_ver[i][0]}-1:0] {i};\n'
	f_logic+=s
	s = f'\t.{i}({i})'
	if cntr!=len(mp_ver):
		s+=','
	s+='\n'
	f_module+=s
	s = 'if (sstr[1] == \"'
	if cntr!=1:
		s = 'else ' + s
	s = '\t\t\t' + s
	s += f'{i}\")\n'
	s += f'\t\t\t\t$sscanf(sstr[0],\"%b\", {i});\n'
	f_if += s
f_module += ');\n'
f_logic+='\n'

with open('template.sv', 'r') as f_template:
	template_lines = f_template.readlines()

for i in template_lines:
	if '{module template}' in i:
		f.write(f_logic)
		f.write(f_module)
	elif '{generated_if}' in i:
		f.write(f_if)
	else:
		f.write(i)


f = open('trace', 'w')
while cnt<len(lines):
	line = lines[cnt]
	cnt+=1
	st = ''
	if line[0]=='b':
		st = line.split()[-1]
	elif line[0]=='r':
		continue
	else:
		st = line[1:-1]
	if line[0] == '#' and int(line[1:])>=end:
		break
	elif line[0] == '#':
		f.write(line)
	elif module=='' or mp.get(st, None)!=None and module in mp[st][1] and mp_ver.get(mp[st][0], None)!=None:
		if line[0]=='b':
			f.write(line.split(' ')[0] + ' ' + mp[st][0] + '\n')
		else:
			f.write('b'+line[0]+' '+mp[st][0]+'\n')
