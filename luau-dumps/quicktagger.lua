--!strict

--[[
	QuickTagger
	
	How to use:
		Clone this script somewhere in ReplicatedStorage for storage.
		Rename the script to the name of the tag you want to add.
		Copy and paste this Script to the instance you want to be tagged during editing / during gameplay.
		The instance will then inherit a tag in the name of this Script.
		The script will then clean up and destroy itself.
	
	- St0rmCast3r
]]

local thisInstance = script.Parent
local tagName = script.Name
local collectionService = game:GetService("CollectionService")

repeat task.wait() until not thisInstance:IsDescendantOf(game:GetService("ReplicatedStorage"))

if not collectionService:HasTag(thisInstance, tagName) then
	collectionService:AddTag(thisInstance, tagName)
end

script:Destroy()
