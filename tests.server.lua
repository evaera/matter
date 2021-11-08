local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.TestEZ).TestBootstrap:run({
	ReplicatedStorage.Matter,
	nil,
	{
		noXpcallByDefault = true
	}
})