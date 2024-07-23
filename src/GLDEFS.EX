//Skybox D3inferno
skybox YZSKY2
{
YZSKY2_N
YZSKY2_E
YZSKY2_S
YZSKY2_W
YZSKY2_T
YZSKY2_B
}

//Skybox D3desert
skybox YZSKY1
{
YZSKY1_N
YZSKY1_E
YZSKY1_S
YZSKY1_W
YZSKY1_T
YZSKY1_B
}

//Skybox D3hell
skybox YZSKY3
{
YZSKY3_N
YZSKY3_E
YZSKY3_S
YZSKY3_W
YZSKY3_T
YZSKY3_B
}

pointlight REDLIGHTPANDEMONIUM
{
    color 1.0 1.0 0.4
    size 32
    offset 0 0 0
}

pointlight FLASHGL1
{
    color 1.0 1.0 0.4
    size 32
    offset 0 0 0
}

object Lightbeam1
{
    frame JTLB { light FLASHGL1 }
}

pointlight FLASHGL2
{
    color 0.7 0.7 0.4
    size 64
    offset 0 0 0
}

object Lightbeam2
{
    frame JTLB { light FLASHGL2 }
}

pointlight FLASHGL3
{
    color 0.7 0.7 0.4
    size 96
    offset 0 0 0
}

object Lightbeam3
{
    frame JTLB { light FLASHGL3 }
}

object Lightprojectile
{
	frame TNT1A { light LILIGHT }
}

flickerlight LILIGHT
{
    color 0.5 0.5 0.0
    size 48
    secondarySize 64
    chance 0
}

Pointlight AcidBall
{
Color 0.0 0.1 0.0
Size 20
}

Pointlight AcidBall2
{
Color 0.0 0.1 0.0
Size 22
}

Pointlight AcidBall3
{
Color 0.0 0.6 0.0
Size 24
}

Pointlight AcidBall4
{
Color 0.0 0.4 0.0
Size 18
}

Object AcidBall
{
Frame MTIFA { Light AcidBall }
Frame MTIFB { Light AcidBall }
Frame MTIFC { Light AcidBall2 }
Frame MTIFD { Light AcidBall3 }
Frame MTIFE { Light AcidBall4 }
}

Pointlight MiniAcidBall
{
Color 0.0 0.1 0.0
Size 10
}

Pointlight MiniAcidBall2
{
Color 0.0 0.1 0.0
Size 12
}

Pointlight MiniAcidBall3
{
Color 0.0 0.6 0.0
Size 14
}

Pointlight MiniAcidBall4
{
Color 0.0 0.4 0.0
Size 10
}

Object MiniAcidBall
{
Frame MTIFA { Light MiniAcidBall }
Frame MTIFB { Light MiniAcidBall }
Frame MTIFC { Light MiniAcidBall2 }
Frame MTIFD { Light MiniAcidBall3 }
Frame MTIFE { Light MiniAcidBall4 }
}

PointLight SSGZombieAttack
{
Color 1.0 0.8 0.2
Size 30
}

Object SSGZombie
{
Frame GPOSF { Light SSGZombieAttack }
}

pointlight MYAURA
{
    color 192 192 192
    size 64
	offset 0 28 0
    dontlightself 1
}


object MarsisPlaya
{
    frame PLAYA { light MYAURA }
    frame PLAYB { light MYAURA }
	frame PLAYC { light MYAURA }
	frame PLAYD { light MYAURA }
	frame PLAYE { light MYAURA }
	frame PLAYF { light MYAURA }
	frame PLAYG { light MYAURA }
}


pointlight TVNOIZELIGHTA1
{
    color 1.0 1.0 1.0
    size 85
}

pointlight TVNOIZELIGHTA2
{
    color 1.1 1.0 1.0
    size 70
}

object TVNOIZELight
{
    frame TNT1A { light TVNOIZELIGHTA1 }
    frame TNT1B { light TVNOIZELIGHTA2 }
}

pointlight Greenalight
{
    color 0.0 0.4 0.4
    size 8
}
object DoorGreenLight { frame TNT1A { light Greenalight }}

pointlight Savealight
{
    color 0.4 0.2 0.4
    size 8
}
object SavePointLight { frame TNT1A { light Savealight }}

// =- Thunder Horn -=



pointlight LIGHTNINGSTRIKE1
{
     color 0.0 5.0 1.0
     size 200
}

pointlight LIGHTNINGSTRIKE2
{
     color 0.0 2.0 1.0
     size 150
}

pointlight LIGHTNINGSTRIKE3
{
     color 0.0 0.0 1.0
     size 175
}

object LightningStrike
{
     frame LTNGA { light LIGHTNINGSTRIKE1 }
     frame LTNGB { light LIGHTNINGSTRIKE2 }
     frame LTNGC { light LIGHTNINGSTRIKE3 }
}

object LightningStrikeSmall
{
     frame LTNGA { light LIGHTNINGSTRIKE1 }
     frame LTNGB { light LIGHTNINGSTRIKE2 }
     frame LTNGC { light LIGHTNINGSTRIKE3 }
}
