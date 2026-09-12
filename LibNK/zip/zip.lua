local addonInfo, privateVars = ...

---------- init namespace ---------

if not LibNK then LibNK = {} end
if not LibNK.Zip then LibNK.Zip = {} end

---------- library public function block ---------

function LibNK.Zip.Compress (data)

	local zippedData = zlib.deflate(zlib.BEST_COMPRESSION)(data, "finish")
	local encodedData = LibNK.Zip.EncodeBase64(zippedData)
	
	return LibNK.Zip.Checksum(encodedData), encodedData
	
end 

function LibNK.Zip.Uncompress (zippedData)

	local decodedData = LibNK.Zip.DecodeBase64(zippedData)
	local data, eof = zlib.inflate()(decodedData)
	
	return data
	
end 

function LibNK.Zip.Checksum(data)

	local checksum = Utility.Storage.Checksum(data)
	local shortCheck = string.sub(checksum, -6)
	
	local bytes = {}
	for hexPair in shortCheck:gmatch("(%x%x)") do
    	table.insert(bytes, string.char(tonumber(hexPair, 16)))
	end
	
	return LibNK.Zip.EncodeBase64(table.concat(bytes))
	
end
