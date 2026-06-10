import re
path = "/Users/jannikschill/Documents/Garten-Simulation/Garten_Simulation/Localization/AppStrings.swift"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Fix Vergiss "%@"
content = content.replace('Vergiss "%@" nicht!', 'Vergiss \\"%@\\" nicht!')
content = content.replace('Don\'t forget "%@"! ', 'Don\'t forget \\"%@\\"! ')
content = content.replace('¡No olvides "%@"! ', '¡No olvides \\"%@\\"! ')
content = content.replace('N\'oublie pas "%@" ! ', 'N\'oublie pas \\"%@\\" ! ')
content = content.replace('Non dimenticare "%@"!', 'Non dimenticare \\"%@\\"! ')
content = content.replace('Não te esqueças de "%@"!', 'Não te esqueças de \\"%@\\"! ')
content = content.replace('忘れないで "％@"！', '忘れないで \\"％@\\"！')
content = content.replace('"%@"을(를) 잊지 마세요!', '\\"%@\\"을(를) 잊지 마세요!')
content = content.replace('Vergeet "%@" niet!', 'Vergeet \\"%@\\" niet!')
content = content.replace('"%@" ifadesini unutmayın!', '\\"%@\\" ifadesini unutmayın!')

# What else? wonder_water.rescue.body_format
content = content.replace('Pflanze "%@" ist am Sterben', 'Pflanze \\"%@\\" ist am Sterben')
content = content.replace('plant "%@" is dying', 'plant \\"%@\\" is dying')
content = content.replace('planta "%@" se está muriendo', 'planta \\"%@\\" se está muriendo')
content = content.replace('plante "%@" est en train de mourir', 'plante \\"%@\\" est en train de mourir')
content = content.replace('pianta "%@" sta morendo', 'pianta \\"%@\\" sta morendo')
content = content.replace('planta "%@" está a morrer', 'planta \\"%@\\" está a morrer')
content = content.replace('식물 "%@"이(가) 죽어가고 있습니다', '식물 \\"%@\\"이(가) 죽어가고 있습니다')
content = content.replace('plant "%@" is stervende', 'plant \\"%@\\" is stervende')
content = content.replace('Bitkiniz "%@" ölüyor', 'Bitkiniz \\"%@\\" ölüyor')

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
