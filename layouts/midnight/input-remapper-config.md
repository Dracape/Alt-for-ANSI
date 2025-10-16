1. backticks
```
modify(ISO_Level3_Shift, key(period)).
key(Left).
modify(ISO_Level3_Shift, key(period))
```

2. braces:
```
ISO_Level3_Shift + f + percent + Left
```

3. brackets:
```
ISO_Level3_Shift + l + emdash + Left
```

4. double quotes:
```
modify(Shift_L, key(apostrophe)).
key(Left).
modify(Shift_L, key(apostrophe))
```

5. normalize asterisk:
```
ISO_Level3_Shift + apostrophe
```

6. parenthesis:
```
ISO_Level3_Shift + o + bar + Left
```

8. apostrophe:
```
if_single(
	parallel(
		repeat(2, key(apostrophe)),
		key(Left)
	),
	key(apostrophe)
)
```
