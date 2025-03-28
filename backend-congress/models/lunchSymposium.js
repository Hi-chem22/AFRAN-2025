const mongoose = require('mongoose');

const lunchSymposiumSchema = new mongoose.Schema({
    dayId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Day',
        required: true
    },
    roomId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Room',
        required: true
    },
    title: {
        type: String,
        required: true
    },
    chairpersons: [{
        type: String
    }],
    time: {
        type: String,
        required: true
    },
    labLogoUrl: {
        type: String
    },
    subsessions: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Subsession'
    }]
}, {
    timestamps: true
});

module.exports = mongoose.model('LunchSymposium', lunchSymposiumSchema); 