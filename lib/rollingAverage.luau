local MAX_SAMPLES = 60

local function addSample(samples, value)
	samples[samples.index or 1] = value
	samples.index = if samples.index then (samples.index % MAX_SAMPLES) + 1 else 1
end

local function getAverage(samples)
	local sum = 0

	for i = 1, #samples do
		sum += samples[i]
	end

	return sum / #samples
end

return {
	addSample = addSample,
	getAverage = getAverage,
}
