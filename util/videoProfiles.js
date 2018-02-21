const VIDEO_PROFILE_ID_SIZE = 8

const videoProfileLookup = {
    "a7ac137a": {name: "P720p60fps16x9", bitrate: "6000k", framerate: 60, aspectratio: "16:9", resolution: "1280x720"},
    "49d54ea9": {name: "P720p30fps16x9", bitrate: "4000k", framerate: 30, aspectratio: "16:9", resolution: "1280x720"},
    "79332fe7": {name: "P720p30fps4x3", bitrate: "3500k", framerate: 30, aspectratio: "4:3", resolution: "960x720"},
    "5ecf4b52": {name: "P576p30fps16x9", bitrate: "1500k", framerate: 30, aspectratio: "16:9", resolution: "1024x576"},
    "93c717e7": {name: "P360p30fps16x9", bitrate: "1200k", framerate: 30, aspectratio: "16:9", resolution: "640x360"},
    "b60382a0": {name: "P360p30fps4x3", bitrate: "1000k", framerate: 30, aspectratio: "4:3", resolution: "480x360"},
    "c0a6517a": {name: "P240p30fps16x9", bitrate: "600k", framerate: 30, aspectratio: "16:9", resolution: "426x240"},
    "d435c53a": {name: "P240p30fps4x3", bitrate: "600k", framerate: 30, aspectratio: "4:3", resolution: "320x240"},
    "fca40bf9": {name: "P144p30fps16x9", bitrate: "400k", framerate: 30, aspectratio: "16:9", resolution: "256x144"}
}

const parseTranscodingOptions = transcodingOptions => {
    let videoProfiles = []
    for (let i = 0; i < transcodingOptions.length; i += VIDEO_PROFILE_ID_SIZE) {
        videoProfiles.push(transcodingOptions.slice(i, i + VIDEO_PROFILE_ID_SIZE))
    }

    return videoProfiles.filter(profile => {
        return profile in videoProfileLookup
    }).map(profile => {
        return videoProfileLookup[profile]
    })
}

module.exports = {
    parseTranscodingOptions
}
