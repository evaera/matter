local createEnum = import("../createEnum")

return createEnum("DataStoreRequestType", {
	GetAsync = 0,
	SetIncrementAsync = 1,
	UpdateAsync = 2,
	GetSortedAsync = 3,
	SetIncrementSortedAsync = 4,
	OnUpdate = 5
})