if(vehicle && !Array.isArray(vehicle)){
    
    const photoDelimiter = ",";
    const notPreReconCount = 25;
    const feedId = 2393;
    const overlayedPhotos = vehicle.photos?.dealer_overlay;
    
    if(overlayedPhotos !== undefined && overlayedPhotos['feed.'+feedId]?.count > notPreReconCount){
        const photoUrlsList = overlayedPhotos['feed.'+feedId]?.photos;
        vehicle.photo_urls = photoUrlsList.join(photoDelimiter);
    }
    
}