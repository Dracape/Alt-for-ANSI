1. BackTicks (`\``)
```
modify(ISO_Level3_Shift, key(period)).
key(Left).
modify(ISO_Level3_Shift, key(period))
```

2. Braces (`{`):
```
ISO_Level3_Shift + f + percent + Left
```

3. Brackets (`[`):
```
ISO_Level3_Shift + l + emdash + Left
```

4. Double-Quotes (`"`):
```
modify(Shift_R, key(apostrophe)).
key(Left).
modify(Shift_R, key(apostrophe))
```

5. Normalize Asterisk (`*`):
```
ISO_Level3_Shift + apostrophe
```

6. Double-Asterisks with r (`*` + `r`):
```
modify(ISO_Level3_Shift, key(apostrophe)).
key(Left).
modify(ISO_Level3_Shift, key(apostrophe))
```

7. Parenthesis (`(`):
```
ISO_Level3_Shift + o + bar + Left
```

8. Apostrophe (`'`):
```
if_single(
    key(period).key(BackSpace).
	parallel(
		repeat(2, key(apostrophe)),
		key(Left)
	),
	key(apostrophe)
)
```

9. Triple period (`.`)
```
repeat(2,key(period))
```
