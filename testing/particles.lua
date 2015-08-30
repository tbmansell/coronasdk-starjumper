Particles = require("particle_candy.lib_particle_candy")
FXLibrary = require("particle_candy.lib_particleEffects_01")

FXLibrary.Initialize()

-- Create emitters
Particles.CreateEmitter("land",      0, 0, 1, true, true, true)
Particles.CreateEmitter("jump",      0, 0, 1, true, true, true)
Particles.CreateEmitter("weather",   display.contentWidth/2, 1, true, true, true)
Particles.CreateEmitter("something", 0, 0, 1, true, true, true)

-- Create particle types
Particles.CreateParticleType("jumpTrails", {
	imagePath			= "particle_candy/Particle_Images/blue-line.png",
	imageWidth			= 10,
	imageHeight			= 10,

	directionVariation	= 0,	
	velocityStart		= 100,
	velocityVariation	= 0,
	rotationVariation	= 0,
	rotationChange		= 0,
	useEmitterRotation	= false,
	alphaStart			= 1.0,
	fadeinSpeed			= 1.0,
	fadeoutSpeed		= -0.5,
	fadeoutDelay		= 500,
	scaleStart			= 0.5,
	scaleVariation		= 3.5,
	scaleInSpeed		= 1.0,
	scaleOutSpeed		= 0.01,
	scaleOutDelay		= 500,
	emissionShape		= 1,
	emissionRadius		= 30,
	killOutsideScreen	= true,
	lifeTime			= 3000
})

Particles.CreateParticleType("MySmoke", {
	imagePath			= "particle_candy/Particle_Images/smoke_whispery_bright.png",
	imageWidth			= 64,	
	imageHeight			= 64,
	weight				= -0.2,
	directionVariation	= 360,	
	velocityVariation	= 50,
	rotationVariation	= 360,
	rotationChange		= 30,
	useEmitterRotation	= false,
	alphaStart			= 0.8,
	fadeinSpeed			= 1.5,
	fadeoutSpeed		= -0.5,
	fadeoutDelay		= 500,
	scaleStart			= 0.5,
	scaleVariation		= 0.5,
	scaleInSpeed		= 1.0,
	scaleOutSpeed		= 0.01,
	scaleOutDelay		= 500,
	emissionShape		= 2,
	emissionRadius		= 30,
	killOutsideScreen	= true,
	lifeTime			= 1000
})

Particles.CreateParticleType ("MyRain", {
	imagePath			= "particle_candy/Particle_Images/purple-rain.png",
	imageWidth			= 24,
	imageHeight			= 128,
	weight				= 0.8,
	xReference			= 4,
	yReference			= 32,
	velocityStart		= 0,
	velocityVariation	= 100,
	directionVariation	= 80,
	autoOrientation		= true,
	useEmitterRotation	= true,
	alphaStart			= 0.0,
	fadeinSpeed			= 3.0,
	fadeoutSpeed		= -0.75,
	fadeoutDelay		= 500,
	scaleStart			= 0.3,
	scaleVariation		= 0.3,
	emissionShape		= 1,
	emissionRadius		= 400,
	killOutsideScreen	= true,
	lifeTime			= 1500,
	--colorStart			= {-.5,  0, -.65},
})



function Particles:jumpTrail(x,y)
	local emitter = Particles.GetEmitter("jump")
	emitter.x, emitter.y = x,y
	emitter.rotation = 200

	Particles.StopEmitter("jump")
	Particles.AttachParticleType("jump", "jumpTrails", 5, 5000, 0)
	Particles.StartEmitter("jump")

	--[[after(1000, function()
		Particles.StopEmitter("jump")
	end)]]
end


function Particles:landDust(x,y)
	local emitter = Particles.GetEmitter("land")
	emitter.x, emitter.y = x,y

	Particles.StopEmitter("land")
	Particles.AttachParticleType("land", "MySmoke", 5, 300, 0)
	Particles.StartEmitter("land")

	after(300, function()
		Particles.StopEmitter("land")
	end)
end


function Particles:startRain()
	Particles.StopEmitter("weather")
	--Particles.GetEmitter("weather").rotation = -10
	Particles.AttachParticleType("weather", "MyRain", 100, 99999, 0)
	Particles.StartEmitter("weather")
end


