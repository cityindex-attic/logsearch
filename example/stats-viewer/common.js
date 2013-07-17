var stats = null;
var ebsVolumes;
var localCpus;
var localMounts;
var localDisks;
var localInterfaces;
var localInterrupts;
var localElasticsearch;

function makeDate(str) {
    // assumes format of %Y-%m-%dT%TZ
    return Date.UTC(
        str.substring(0, 4),
        str.substring(5, 7),
        str.substring(8, 10),
        str.substring(11, 13),
        str.substring(14, 16),
        str.substring(17, 19)
    );
}

// http://codeaid.net/javascript/convert-size-in-bytes-to-human-readable-format-(javascript)
function convertBytes(bytes)
{  
    var precision = 1;
    var kilobyte = 1024;
    var megabyte = kilobyte * 1024;
    var gigabyte = megabyte * 1024;
    var terabyte = gigabyte * 1024;
   
    if ((bytes >= 0) && (bytes < kilobyte)) {
        return bytes.toFixed(precision) + ' B';
 
    } else if ((bytes >= kilobyte) && (bytes < megabyte)) {
        return (bytes / kilobyte).toFixed(precision) + ' KB';
 
    } else if ((bytes >= megabyte) && (bytes < gigabyte)) {
        return (bytes / megabyte).toFixed(precision) + ' MB';
 
    } else if ((bytes >= gigabyte) && (bytes < terabyte)) {
        return (bytes / gigabyte).toFixed(precision) + ' GB';
 
    } else if (bytes >= terabyte) {
        return (bytes / terabyte).toFixed(precision) + ' TB';
 
    } else {
        return bytes + ' B';
    }
}

function gatherStats(name) {
    var parsed = [];

    if (!stats[name]) {
        alert('Stats named "' + name + '" are not available.');

        return {}
    }

    if ('aws-' == name.substr(0, 4)) {
        Array.each(
            stats[name].Datapoints,
            function (v) {
                parsed.push([ makeDate(v.Timestamp), v.Average ]);
            }
        );
    } else {
        Object.each(
            stats[name],
            function (v, k) {
                parsed.push([ makeDate(k), v ]);
            }
        );
    }

    parsed.sort(
        function (a, b) {
            if (a[0] == b[0]) {
                return 0;
            }

            return a[0] < b[0] ? -1 : 1;
        }
    );

    return parsed;
}

function gatherStatsAggregate(merge) {
    var merged = {};

    Array.each(
        merge,
        function (mergev) {
            Array.each(
                mergev,
                function (v) {
                    if (!merged[v[0]]) {
                        merged[v[0]] = v;
                    } else {
                        merged[v[0]][1] += v[1];
                    }
                }
            );
        }
    );

    return Object.values(merged);
}

function gatherStatsRate(name) {
    var stats = gatherStats(name);
    var last = stats[Object.keys(stats)[0]][1];

    Object.each(
        stats,
        function (v, k) {
            var tmp = stats[k][1];
            stats[k][1] = stats[k][1] - last;
            last = tmp;
        }
    );

    return stats;
}

function statisticalSum(subset) {
    var c = 0;

    Object.values(subset).each(
        function (s) {
            c += s[1];
        }
    );

    return c;
}

function statisticalAvg(subset) {
    return statisticalSum(subset) / Object.values(subset).length;
}

function statisticalMin(subset) {
    return Math.min.apply(null, Object.values(subset).map(function (v) { return v[1]; }));
}

function statisticalMax(subset) {
    return Math.max.apply(null, Object.values(subset).map(function (v) { return v[1]; }));
}

function createChart(obj) {
    var chart = new Element(
        'div',
        {
            styles : {
                height : 300,
                marginBottom : '20px'
            }
        }
    );

    $('charts').adopt(chart);

    new Highcharts.Chart(
        Object.merge(
            {
                chart : {
                    type : 'areaspline',
                    renderTo : chart
                },
                plotOptions: {
                    series: {
                        animation: false,
                        marker: {
                            enabled: false
                        }
                    }
                },
                xAxis: {
                    type: 'datetime'
                },
                tooltip: {
                    formatter: function() {
                            return '<b>'+ this.series.name +'</b><br/>'+
                            Highcharts.dateFormat('%e. %b', this.x) +': '+ this.y;
                    }
                }
            },
            obj
        )
    );
}

function init() {
    localMounts = Object.keys(stats)
        .filter(
            function (v) {
                return v.match(/collectd\/df\/df-.*/);
            }
        ).map(
            function (v) {
                return v.replace(/collectd\/df\/df-([^\/]+)\/.*/, '$1');
            }
        ).filter(
            function (v, i, arr) {
                return arr.lastIndexOf(v) === i;
            }
        )
    ;

    localMounts.sort();

    localDisks = Object.keys(stats)
        .filter(
            function (v) {
                return v.match(/collectd\/disk-.*/);
            }
        ).map(
            function (v) {
                return v.replace(/collectd\/disk-([^\/]+)\/.*/, '$1');
            }
        ).filter(
            function (v, i, arr) {
                return arr.lastIndexOf(v) === i;
            }
        )
    ;

    localDisks.sort();

    localCpus = Object.keys(stats)
        .filter(
            function (v) {
                return v.match(/collectd\/cpu-.*/);
            }
        ).map(
            function (v) {
                return v.replace(/collectd\/cpu-([^\/]+)\/.*/, '$1');
            }
        ).filter(
            function (v, i, arr) {
                return arr.lastIndexOf(v) === i;
            }
        )
    ;
    
    localCpus.sort();

    localInterfaces = Object.keys(stats)
        .filter(
            function (v) {
                return v.match(/collectd\/interface\/if_octets-.*/);
            }
        ).map(
            function (v) {
                return v.replace(/collectd\/interface\/if_octets-([^\/]+)\/.*/, '$1');
            }
        ).filter(
            function (v, i, arr) {
                return arr.lastIndexOf(v) === i;
            }
        )
    ;

    localInterfaces.sort();

    localInterrupts = Object.keys(stats)
        .filter(
            function (v) {
                return v.match(/collectd\/irq\/irq-.*/);
            }
        ).map(
            function (v) {
                return v.replace(/collectd\/irq\/irq-([^\/]+)\/.*/, '$1');
            }
        ).filter(
            function (v, i, arr) {
                return arr.lastIndexOf(v) === i;
            }
        )
    ;

    localInterrupts.sort();
    
    ebsVolumes = Object.keys(stats)
        .filter(
            function (v) {
                return v.match(/aws-ebs\/vol-.*/);
            }
        ).map(
            function (v) {
                return v.replace(/aws-ebs\/vol-([^\/]+)\/.*/, '$1');
            }
        ).filter(
            function (v, i, arr) {
                return arr.lastIndexOf(v) === i;
            }
        )
    ;

    ebsVolumes.sort();
    
    localElasticsearch = Object.keys(stats)
        .filter(
            function (v) {
                return v.match(/collectd\/elasticsearch-.*/);
            }
        ).map(
            function (v) {
                return v.replace(/collectd\/elasticsearch-([^\/]+)\/.*/, '$1');
            }
        ).filter(
            function (v, i, arr) {
                return arr.lastIndexOf(v) === i;
            }
        )
    ;

    ebsVolumes.sort();

    redraw();
}