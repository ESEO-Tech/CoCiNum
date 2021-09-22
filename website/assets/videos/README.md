
Ré-encodage en retirant le son (peut réduire le poids de la vidéo) :
```
ffmpeg -i $SRC -vf "hflip,vflip" -an $DEST
```

Rotation de 180 degrés en retirant le son :

```
ffmpeg -i $SRC -vf "hflip,vflip" -an $DEST
```
