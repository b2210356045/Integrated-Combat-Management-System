`timescale 1us / 1ps

module ICMS(
    input CLK,
    input RST,

    input radar_echo,
    input scan_for_target,
    input [31:0] jet_speed,
    input [31:0] max_safe_distance,
    input [5:0] wind,
    input thunderstorm,
    input [1:0] visibility,
    input signed [7:0] temperature,

    output radar_pulse_trigger,
    output [31:0] distance_to_target,
    output safe_to_engage,
    output threat_detected,
    output emergency_landing_alert,
    output [1:0] ECSU_state,  
    output [1:0] ARTAU_state
);

   // Your code goes here.
   wire w1, w2;
    ARTAU ARTAU1(
        .radar_echo(radar_echo),
        .scan_for_target(scan_for_target),
        .jet_speed(jet_speed),
        .max_safe_distance(max_safe_distance),
        .CLK(CLK),
        .RST(RST), 
        .radar_pulse_trigger(radar_pulse_trigger),
        .distance_to_target(distance_to_target),
        .threat_detected(threat_detected),
        .ARTAU_state(ARTAU_state)
    );
    ECSU ECSU1(
        .wind(wind),
        .thunderstorm(thunderstorm),
        .visibility(visibility),
        .temperature(temperature),
        .CLK(CLK),
        .RST(RST),
        .severe_weather(w1),
        .emergency_landing_alert(emergency_landing_alert),
        .ECSU_state(ECSU_state)
    );
    not (w2, w1);
    and (safe_to_engage, threat_detected, w2);


endmodule