A lot of it is pretty self explanatory but

# Prerequisites 
Use asset ripper to rip your models (Asset studio doesnt grab tangents?)


# Usage
Your Diffuse texture goes to "Diffuse Texture" and "Outline Texture" (don't ask I only wrote how the game did it)

"Control map" is your Multi Texture

Spec tex is obvious

for Mayu (Eyebrow) set stencil value to 1 for things you dont want it to pass through

Transparent2Tex is handled pretty much as is just use the alpha mask (black and white texture)

<img width="907" alt="shader" src="https://user-images.githubusercontent.com/105132829/170176110-985e47eb-c745-47fa-932b-ae3cbf8a37b5.PNG">
